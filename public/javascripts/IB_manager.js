var uploader = null;
function createUploader(){            
  uploader = new qq.FileUploader({
    element: document.getElementById('IB_dropboxContainer'),
    action: '/images.json',
    maxConnections: 1,
    /*params: {"image":{"album":null,"artist":"Mark Lee","category":"Classical Art","created_at":"2010-12-29T00:15:39Z","genre":"Classical Art","geotag":null,"location":null,"notes":null,"public":null,"tags":null,"title":"This is a test title!","year": 2012}},*/
    params: imageMetaParams,
    debug: true,
    onSubmit: function(id, fileName){
      collectParams(); // Grab the variables from the UI for the params
    },
    onComplete: function(id, fileName, responseJSON){
      if(responseJSON.success){
        // Image made it
        // Get image info from
        // responseJSON.id
        alert(responseJSON.length)
        if(responseJSON.length == 1){
          // Find image year from last 4 digits on file name.
          
        }
      }
      
      resetImageSelectionEvents();
    }
  });           
}

function setupDropdownEvents(){
  // setup the genre list selector tools
  $('#IB_genreList').change(function(){
    $('#IB_current_genre').text($("#IB_genreList option:selected").val());
    $('#IB_genre_checkbox').attr('checked', true);
  })
  
  $('#IB_categoryList').change(function(){
    $('#IB_current_category').text($("#IB_categoryList option:selected").val());
    $('#IB_category_checkbox').attr('checked', true);
  })
  
  $('#IB_typeList').change(function(){
    $('#IB_current_type').text($("#IB_typeList option:selected").val());
    $('#IB_type_checkbox').attr('checked', true);
  })
  
}

$(document).ready(function() {
  createUploader();
  
  checkForPassedImages();
  
  setupDropdownEvents();
  
  $('#IB_managerSave').click(function(){
    updateCurrentImagesMeta();
    
    /*// Disable button from being clicked again
    $(this).css('color', '#c0c0c0');
    $(this).parent().hover(function(){$(this).css('background', 'none');}, function(){$(this).css('background', 'none');});
    $(this).css('background', '#ccc');
    $(this).click(function(event){event.stopPropagation();});*/

  }) 
  
  $('#IB_searchButtonWrap').click(function(){
    window.location ='/images?search=true';
  });
  
  $('#IB_browseBack, #IB_managerCancel').click(function(){
    // Return user to browser
    window.location = '/images';
  });
  
  // Set all input area's to check the checkbox if
  // user types in input field
  $('#IB_title_input').keyup(function() { $('#IB_title_checkbox').attr("checked", true) });
  $('#IB_album_input').keyup(function() { $('#IB_album_checkbox').attr("checked", true) });
  $('#IB_author_input').keyup(function() { $('#IB_author_checkbox').attr("checked", true) });
  $('#IB_location_input').keyup(function() { $('#IB_location_checkbox').attr("checked", true) });
  $('#IB_year_input').keyup(function() { $('#IB_year_checkbox').attr("checked", true) });
  $('#IB_notes_input').keyup(function() { $('#IB_notes_checkbox').attr("checked", true) });
  $('#IB_date_input').keyup(function() { $('#IB_date_checkbox').attr("checked", true) });
  $('#IB_user_input').keyup(function() { $('#IB_user_checkbox').attr("checked", true) });
  $('#IB_geotag_input').keyup(function() { $('#IB_geotag_checkbox').attr("checked", true) });
  $('.IB_managerTagInput').keyup(function() { $('.IB_managerTagCheckbox').attr("checked", true) });
  
  $("#IB_selectAllImages").click(function() {
    $("#IB_dropboxImages li").addClass("selected");
    //ajax call to get all common property values for all selected images
    displaySelectedImageMetaData();
  });
  
  $("#IB_selectNoneImages").click(function() {
    $("#IB_dropboxImages li").removeClass("selected");
    //ajax call to get all common property values for all selected images
    displaySelectedImageMetaData();
  });
  
  // Auto-fill GEOLOCATION tag
  autoFillGeo();
});

var autoFillGeo = function(){
  navigator.geolocation.getCurrentPosition(geoSuccess, geoError);
}

function geoError(error){
  alert("geolocation error : " + error);
}

function geoSuccess(position) {
  // Temp solution.
  var lat = position.coords.latitude;
  var lng = position.coords.longitude;
  $('#IB_geotag_input').val(lng + ' / ' + lat);
}

var passedImages = [];

var checkForPassedImages = function(){
  var query = window.location.search;
  if (query.substring(0, 1) == '?') {
    query = query.substring(1);
  }
  
  var data = query.split('=');
  if(data[0] == ""){
    // EMPTY
  } else {
    passedImages = data[data.length-1].split(',');
  
    // These are the image ID's we recieved
    displayImages(passedImages);
  }
  
};

var displayImages = function(images){
  // Request JSON
  $.getJSON("/images.json?ids=" + images.toString(),
    function(images) {
      for(var u = 0; u < images.length; u++){
        var newImage = '<li class="qq-upload-success"><img width="120" height="120" src="/images/uploads/' + images[u].id + '-126x126.' + images[u].format + '"></li>';
        $('#IB_dropboxImages').append(newImage);
      }
      
      resetImageSelectionEvents();
    });
  
  
  
  // temp hack!
  // IF 1 image is loaded, grab its tags
  if(images.length == 1){
    // Get tags from image & set
    $.getJSON("/images/" + images[0] + ".json",
    function(data) {
      //alert("TAGS :: " + data.image.tags)
      var newTags = data.image.tags;
      $('.IB_managerTagInput').val(newTags);
      
    });
    
  }
}

var updateSelectedList = function(){
  $('#IB_dropboxImages li').each(function(){
    if($(this).hasClass('selected')){
      var selectedImageID = getImageIDFromURL($(this).find('img').attr('src'));
      
      // Check for duplicate
      var hasDupe = false;
      for(var i = 0; i < currentSelectedImages.length; i++){
        if(currentSelectedImages[i] == selectedImageID){
          hasDupe = true;
        }
      }
      
      if(!hasDupe){
        currentSelectedImages.push(selectedImageID);
      }
    }
  })
}

// Returns an IMAGE ID based on its FILE name
var getImageIDFromURL = function(filePath){
  var imgSrc = filePath.split('/');
  var imgFile = imgSrc[imgSrc.length - 1].split('.');
  var selectedImageID = imgFile[0];
  
  return selectedImageID;
}

var resetImageSelectionEvents = function(){
  // Set events
  $("#IB_dropboxImages li").unbind();
  
  $("#IB_dropboxImages li").click(function() {
    if ($(this).hasClass("selected")) {
      $(this).removeClass("selected");
      updateSelectedList();
    } else {
      $(this).addClass("selected");
      updateSelectedList();
      //ajax call to get all common property values for all selected images
      
      displaySelectedImageMetaData();
    }
  });
}


// Multi image meta-data handler
var currentSelectedImages = [];


// JSON Obj to check data against
// for multi-image meta data handler



var displaySelectedImageMetaData = function(){
  // Get images data
  var imageIDString = currentSelectedImages.toString();
  
  $.getJSON("/images.json?ids=" + imageIDString,
    function(images) {
      checkForSimilarMetaData(images);
      currentSelectedImages = [];
    });
}

var checkForSimilarMetaData = function(images){
  // create temp var
  var similarMetaData = {"image":{"album":"","artist":"","category":"","created_at":"","format":null,"genre":"","geotag":null,"id":null,"location":"","notes":"","public":null,"tags":null,"title":"","updated_at":"","uploaded_at":null,"uploaded_by":"","year":null}}

  // check if it has more than 1 image
  if(images.length > 1){
    // First object
    var obj = images;
    
    // each param checks against all others
    for(param in obj[0].image){
     var valuesMatch = true;
     var valueIndex = '';
     
     // Check for match OLD WAY
     for(var u = 1; u < images.length; u++){
      //alert("FOR :: " + param + " ::\n" + images[0].image[param] + ' / ' + images[u].image[param]);
      
      if(images[0].image[param] != images[u].image[param]){
        valuesMatch = false;
      } else {
        valueIndex = param;
        //alert("MATCH + " + param)
      }
     }
     
     // After checking all images, see if any match
     if(valuesMatch){
      //alert("values match " + param)
      var obj = images[0];
 
      // Values all matched, display them on UI
      similarMetaData.image[param] = images[0].image[param];
      //alert('match + ' +  obj.image[param])
     }
     
    }
    // Display the data collected
    displayMetaData(similarMetaData);
  } else {
    // only one image, display meta data
    displayMetaData(images[0]);
  }
}

var displayMetaData = function(metadata){
  // Clean up any old meta data
  $('.meta-value').empty();
  $("input[type='checkbox']").attr('checked', false);
  
  // Set the top check boxes
  $('#IB_current_type span').html(metadata.image.section);
  $('#IB_current_category').html(metadata.image.category);
  $('#IB_current_genre').html(metadata.image.genre);
  
  // Set Meta Fields
  $('#IB_title_input').val(metadata.image.title);
  $('#IB_album_input').val(metadata.image.album);
  $('#IB_author_input').val(metadata.image.artist);
  $('#IB_location_input').val(metadata.image.location);
  $('#IB_year_input').val(metadata.image.year);
  $('#IB_notes_input').val(metadata.image.notes);
  $('#IB_date_input').val(metadata.image.created_at);
  $('#IB_user_input').val(metadata.image.uploaded_by);
  $('#IB_geotag_input').val(metadata.image.geotag);
  $('.IB_managerTagInput').val(metadata.image.tags);
}

// Check to make sure there are images selected
var imagesSelected = false;

var updateCurrentImagesMeta = function(){
  // Collect data from fields for JSON
  collectParams();
  // Get currently selected images
  imagesSelected = false;
   
  $('#IB_dropboxImages li').each(function(){
    if($(this).hasClass('selected')){
      imagesSelected = true; // an image has been found!
      
      // Get current ID
      var currentImageID = getIDFromUrl($(this).find('img').attr('src'));
      
      // Make call & set data
      $.ajax({
          url: "/images/" + currentImageID + ".json",
          type: 'PUT',
          contentType: 'application/json',
          data: JSON.stringify(imageMetaParams),
          dataType: 'json'
      });
    }
  });
  
  if(!imagesSelected){
    // No Images were selected
    alert('No images selected.')
  }
  
  
}


// removes the extension & returns ID number from image URL
var getIDFromUrl = function(filename){
  var temp = filename.split('/');
  var temp2 = temp[temp.length-1].split('.');
  return temp2[0];
}

// Create params obj for updating meta data
var imageMetaParams = { image: {} };


function collectParams(){
  if($('#IB_category_checkbox').attr("checked")){
    imageMetaParams.image.category =  $('#IB_categoryList').val();
  }
  
  if($('#IB_genre_checkbox').attr("checked")){
    imageMetaParams.image.genre =  $('#IB_genreList').val();
  }
  
  if($('#IB_type_checkbox').attr("checked")){
    imageMetaParams.image.section =  $('#IB_typeList').val();
  }
  
  // Get the rest of the parameters
  
  if($('#IB_title_checkbox').attr("checked")){
    imageMetaParams.image.title =  $('#IB_title_input').val();
  }
  
  if($('#IB_author_checkbox').attr("checked")){
    imageMetaParams.image.artist =  $('#IB_author_input').val();
  }
  
  if($('#IB_album_checkbox').attr("checked")){
    imageMetaParams.image.album =  $('#IB_album_input').val();
  }
  
  if($('#IB_location_checkbox').attr("checked")){
    imageMetaParams.image.location =  $('#IB_location_input').val();
  }
  
  if($('#IB_year_checkbox').attr("checked")){
    imageMetaParams.image.year =  $('#IB_year_input').val();
  }
  
  if($('#IB_notes_checkbox').attr("checked")){
    imageMetaParams.image.notes =  $('#IB_notes_input').val();
  }
  
  if($('#IB_date_checkbox').attr("checked")){
    // todo : figure out if this date field is used
    // server auto-sets date of upload
    imageMetaParams.image.uploaded_at =  $('#IB_date_input').val();
  }
  
  if($('#IB_user_checkbox').attr("checked")){
    imageMetaParams.image.uploaded_by =  $('#IB_user_input').val();
  }
  
  if($('#IB_geotag_checkbox').attr("checked")){
    imageMetaParams.image.geotag =  $('#IB_geotag_input').val();
  }
  
  if($('.IB_managerTagCheckbox').attr("checked")){
    imageMetaParams.image.tags =  $('.IB_managerTagInput').val();
  }

}