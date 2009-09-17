##
# Copyright (c) The Nambu Network Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
# is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
# IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
##

require 'net/imap'
require 'digest/sha1'
require 'actionmailer'

## Add plain ("PLAIN") as an authentication type. This is taken from:
##   http://svn.ruby-lang.org/cgi-bin/viewvc.cgi/trunk/lib/net/imap.rb?revision=7657&view=markup&pathrev=10966

class PlainAuthenticator
  def process(data)
    return "\0#{@user}\0#{@password}"
  end

  private
  def initialize(user, password)
    @user = user
    @password = password
  end
end
Net::IMAP.add_authenticator "PLAIN", PlainAuthenticator

class NCImapResult
  attr_accessor :date, :from, :to, :subject, :message_path, :image_path, :error
end

class NCImapNoAttachmentException < Exception
  attr_accessor :result

  def initialize(result)
    @result = result
    super(".. Email Message Missing Image Attachment")
  end
end

class NCImap
  IMG_FOLDER = "/tmp/uploads_pic.im.images"
  MSG_FOLDER = "/tmp/uploads_pic.im.messages"
  
  def initialize(user, password, address, port = 143, auth = 'PLAIN', ssl = false, use_login = false)
    @address    = address
    @port       = port
    @user       = user
    @password   = password
    @auth       = auth
    @ssl        = ssl
    @index      = 0
    @use_login  = use_login

    FileUtils.mkdir_p(IMG_FOLDER)
    FileUtils.mkdir_p(MSG_FOLDER)
  end
  
  # process the first email on the imap server
  # if the email doesn't have an image attachment, a NCImapNoAttachmentException exception will be raised
  # NCImapNoAttachmentException has attr named result which contains email info.

  def fetch
    messages = @connection.uid_search(['ALL'])
    RAILS_DEFAULT_LOGGER.info "MESSAGES Found? [#{messages.size}]"
    RAILS_DEFAULT_LOGGER.info "MESSAGE UIDS #{messages.inspect}"

    if messages.size > @index
      RAILS_DEFAULT_LOGGER.info ".. Fetching INDEX [#{@index}] ..."
      @index += 1
      result = process_upload(messages[@index - 1])
      return result
    else
      return nil end
  end
  
  def connect
    @connection = Net::IMAP.new(@address, @port, @ssl)
    if @use_login
      @connection.login(@user, @password)
    else
      @connection.authenticate(@auth, @user, @password)
    end
    @connection.select('INBOX')
  rescue => e
    RAILS_DEFAULT_LOGGER.info ".. NCImap(): IMAP Connected Failed"
    raise NCNotAuthorized.new(e.message)
  end
  def disconnect
    @connection.expunge
    @connection.logout
  end

  protected
  def process_upload(uid)
    message = @connection.uid_fetch(uid,'RFC822').first.attr['RFC822']
    ## RAILS_DEFAULT_LOGGER.info "PROCESSING MESSAGE #{message.inspect}"

    image, result = nil, NCImapResult.new
    mail = TMail::Mail.parse(message)
    if mail.attachments
      mail.attachments.each do |attachment|
        if image?(attachment.content_type)
          image = attachment
          break
        end
      end
    end
    self.delete(uid)

    if image
      RAILS_DEFAULT_LOGGER.info ".. Image UPLOADED"

      image_path = File.join(IMG_FOLDER, self.get_file_name(image.original_filename, IMG_FOLDER))
      File.open(image_path, File::WRONLY|File::TRUNC|File::CREAT) do |imgf|
        imgf << image.read
      end

      message_path = File.join(MSG_FOLDER,
                               get_file_name(Digest::SHA1.hexdigest("#{mail.subject} #{mail.from.to_s} #{mail.date.to_s}")[0..7] + ".txt", MSG_FOLDER))
      File.open(message_path, File::WRONLY|File::TRUNC|File::CREAT) do |ms|
        ms << mail.body
      end

      result.image_path = image_path
      result.message_path = message_path
      result.date    = mail.date
      result.from    = mail.from
      result.to      = mail.to
      result.subject = mail.subject
      ## RAILS_DEFAULT_LOGGER.info ".. UPLOAD Result #{result.inspect}"
      return result

    else
      ## RAILS_DEFAULT_LOGGER.info ".. NCImap: Email MISSING Image Attachment"
      raise NCImapNoAttachmentException.new(@result) end
  end
  
  def get_file_name(name, folder)
    while File.exist?(File.join(folder, name))
      name = "1#{name}"
    end
    return name
  end
  
  def image?(content_type)
    return @@content_types.include?(content_type)
  end

  def delete(uid)
    @connection.uid_store(uid, "+FLAGS", [:Seen, :Deleted])
  end

  @@content_types = [
    'image/jpeg',
    'image/pjpeg',
    'image/jpg',
    'image/gif',
    'image/png',
    'image/x-png',
    'image/jpg',
    'image/jp_',
    'application/jpg',
    'application/x-jpg',
    'image/x-xbitmap',
    'application/png',
    'application/x-png'
  ]
end

