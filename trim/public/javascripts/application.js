/*----------UNIVERSAL DOM LAYOUT MANIPULATION---------*/
// Notes:
// -- no getComputedStlye() in Safari (I shall defend Safari no more)
// -- IE seems to dislike Element.getStyle()

function loGetPanelHeight(id) {
  if (isIE) { return($(id).clientHeight); }
  else {
	tmps = Element.getStyle(id, 'height');
	return(parseInt(tmps.substr(0, tmps.length - 2)));	
  }
}
function loGetPanelWidth(id) {
  if (isIE) { return($(id).clientWidth); }
  else {
    tmps = Element.getStyle(id, 'width');
	return(parseInt(tmps.substr(0, tmps.length - 2)));	
  }
}
function loPanelIsOpen(id) {
  var isOpen = false;
  if (document.getElementById(id) != null) {
    if ($(id).style.display != "none") { isOpen = true; }
  }
  return(isOpen);
}
function loPanelExists(id) {
  if (document.getElementById(id) != null) { return(true); }
  else { return(false); }
}
function loPanelHasVerticalScroll(id) {
  var hasScroll = false;
  if (isIE) { if ($(id).scrollHeight  > $(id).clientHeight) { hasScroll = true; } }
  else {      if ($(id).scrollHeight != $(id).clientHeight) { hasScroll = true; } }
  return(hasScroll);
}

/** JS for tr.im Textarea submits on return **/
function submitTrimUrlForm() {
  new Ajax.Request('/url/create/', {
    asynchronous: true,
    evalScripts: true,
    onComplete: function(request) {
      $('progress_url').setStyle({visibility: 'hidden'})
    },
    onLoading: function(request) {
      $('progress_url').setStyle({visibility: 'visible'});
      $('errors_trim').update('');
    },
    parameters: Form.serialize(document.URLF)
  });
  return false;
}
function sTF() {
  new Ajax.Request('/tweet/', {
    asynchronous: true,
    evalScripts: true,
    onComplete: function(request) {
      $('progress_tweet').setStyle({visibility: 'hidden'})
    },
    onLoading: function(request) {
      $('progress_tweet').setStyle({visibility: 'visible'});
      $('errors_tweet').update('');
    },
    parameters: Form.serialize(document.URLT)
  });
  return false;
}

/** JS for Tweet textarea counter **/
function updateTweetTextAreaCount(value, display_id)
{
  $(display_id).update('' + 140 - value.length);
  if ((140 - value.length) <= 20) {
	  $(display_id).setStyle({color: '#97391D'});
  }
  else {
	  $(display_id).setStyle({color: '#333'});	
  }
  return true;
}

var redirectURL = "";
var redirectSeconds = 0;
function markletRedirect(url, seconds)
{
  redirectURL = url;
  redirectSeconds = seconds;
  $('referer_countdown').update(redirectSeconds);
  if (redirectSeconds > 0) {
  	redirectSeconds -= 1;
    setTimeout("markletRedirect(redirectURL, redirectSeconds)", 1000);
  }
  else {
  	location.href = redirectURL;
  }
}

/** JS for pic.im upload callback. */

TrimWebsite = {
  picimreponse: function() {
    alert("here"); 
  }  
}

/** JS to copy the URL to the clipboard automatically. */
function clipboardCopy(text2copy) {
  if (window.clipboardData) {
    window.clipboardData.setData("Text",text2copy);
  } else {
    var flashcopier = 'flashcopier';
    if (!document.getElementById(flashcopier)) {
      var divholder = document.createElement('div');
      divholder.id = flashcopier;
      document.body.appendChild(divholder);
    }
    document.getElementById(flashcopier).innerHTML = '';
    var divinfo = '<embed src="/flash/tools/_clipboard.swf" FlashVars="clipboard=' + escape(text2copy) + '" width="0" height="0" type="application/x-shockwave-flash"></embed>';
    document.getElementById(flashcopier).innerHTML = divinfo;
  }
}

/* JS to update the value of form elements | Form.Element.setValue("fieldname/id", "valueToSet") */
Form.Element.setValue = function(element, newValue) {
    element_id = element;
    element = $(element);
    if (!element){element = document.getElementsByName(element_id)[0];}
    if (!element){return false;}
    var method = element.tagName.toLowerCase();
    var parameter = Form.Element.SetSerializers[method](element,newValue);
}

Form.Element.SetSerializers = {
  input: function(element,newValue) {
    switch (element.type.toLowerCase()) {
      case 'submit':
      case 'hidden':
      case 'password':
      case 'text':
        return Form.Element.SetSerializers.textarea(element,newValue);
      case 'checkbox':
      case 'radio':
        return Form.Element.SetSerializers.inputSelector(element,newValue);
    }
    return false;
  },

  inputSelector: function(element,newValue) {
    fields = document.getElementsByName(element.name);
    for (var i=0;i<fields.length;i++){
      if (fields[i].value == newValue){
        fields[i].checked = true;
      }
    }
  },

  textarea: function(element,newValue) {
    element.value = newValue;
  },

  select: function(element,newValue) {
    var value = '', opt, index = element.selectedIndex;
    for (var i=0;i< element.options.length;i++){
      if (element.options[i].value == newValue){
        element.selectedIndex = i;
        return true;
      }        
    }
  }
}

function unpackToForm(data){
   for (i in data){
     Form.Element.setValue(i,data[i].toString());
   }
}
