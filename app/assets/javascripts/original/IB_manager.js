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
        if(responseJSON.length == 1){
          // Find image year from last 4 digits on file name.
          
        }
      }
      
      resetImageSelectionEvents();
    }
  });           
}

function checkForcedParams(){
  // Make sure user has selected a TYPE/CATEGORY/GENRE
  // before allowing uploads
  var genreList = $("#IB_genreList option:selected").val();
  var catList = $("#IB_categoryList option:selected").val();
  var typeList = $("#IB_typeList option:selected").val();
  
  if((genreList != "None") && (catList != "None") && (typeList != "None")){
    // Hide upload cover
    $('#IB_dropboxCover').fadeOut();
  }
}

function setupDropdownEvents(){
  // setup the genre list selector tools
  $('#IB_genreList').change(function(){
    if($("#IB_genreList option:selected").val() != "Choose"){
      $('#IB_current_genre').text($("#IB_genreList option:selected").val());
      $('#IB_genre_checkbox').attr('checked', true);
      checkForcedParams();
    }
  })
  
  $('#IB_categoryList').change(function(){
    if($("#IB_categoryList option:selected").val() != "Choose"){
      $('#IB_current_category').text($("#IB_categoryList option:selected").val());
      $('#IB_category_checkbox').attr('checked', true);
      checkForcedParams();
    }
    if($('#IB_dropboxCover').css('display') == 'none'){
      $('#IB_dropboxCover').fadeIn();
    }
    
    setGenreOptions();
    
    $('#IB_current_genre').html('Choose')
  })
  
  $('#IB_typeList').change(function(){
    if($("#IB_typeList option:selected").val() != "Choose"){
      $('#IB_current_type').text($("#IB_typeList option:selected").val());
      $('#IB_type_checkbox').attr('checked', true);
      checkForcedParams();
    }
  })
  
}

function setGenreOptions(){
  if ($("#IB_typeList option:selected").val() == "Bedsheets") {
    var newGenres = "<option value='None'></option>";
    var genreList = ["City","Design","Earth","Far East","Indigenous","Landscapes","Nightmares","Plants","Skies","Space","Textures","Travel","Water"];
    for(var i = 0; i < genreList.length; i++) {
      newGenres += "<option value='"+genreList[i]+"'>"+genreList[i]+"</option>";
    }
    $('#IB_genreList').html(newGenres);
  }
  if($("#IB_categoryList option:selected").val() == "Modern Art"){
    var newGenres = '<option value="None"></option><option value="Paintings">Paintings</option><option value="Digital">Digital</option><option value="Fantasy">Fantasy</option> <option value="Visionary">Visionary</option><option value="Graphics">Graphics</option>';
    
    $('#IB_genreList').html(newGenres);
  } else if($("#IB_categoryList option:selected").val() == "Classical Art"){
    var newGenres = '<option value="None"></option><option value="Europe">Europe</option><option value="Eurasia">Eurasia</option><option value="Asia">Asia</option><option value="Americas">Americas</option><option value="Africa">Africa</option><option value="Australia">Australia</option>';
    
    $('#IB_genreList').html(newGenres);
  } else if($("#IB_categoryList option:selected").val() == "Photo"){
    var newGenres = '<option value="None"></option><option value="People">People</option><option value="Places">Places</option><option value="Things">Things</option><option value="Concept">Concept</option><option value="Animals">Animals</option>';
    
    $('#IB_genreList').html(newGenres);
  }
}

$(document).ready(function() {
  createUploader();
  
  checkForPassedImages();
  
  setupDropdownEvents();
  
  $('#IB_managerSave').click(function(){
    updateCurrentImagesMeta();
  }) 
  
  $('#IB_managerUpdate').click(function(){
    updateCurrentImagesMeta('update');
  }) 
  
  $('#IB_searchButtonWrap').click(function(){
    window.location ='/images?search=true';
  });
  
  $('#IB_browseBack, #IB_managerCancel').click(function(){
    // Empty fields
    emptyAllFields();
    
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
  $('#IB_source_input').keyup(function() { $('#IB_source_checkbox').attr("checked", true) });
  
  $("#IB_selectAllImages").click(function() {
    $("#IB_dropboxImages li").addClass("selected");
    //ajax call to get all common property values for all selected images
    updateSelectedList();
  });
  
  $("#IB_selectNoneImages").click(function() {
    $("#IB_dropboxImages li").removeClass("selected");
    //ajax call to get all common property values for all selected images
    updateSelectedList();
  });
  
  // Auto-fill GEOLOCATION tag
  autoFillGeo();
  
  // Delete button functionality
  $('#IB_deleteButton').click(function(){
    var selectedImages = [];
    $('#IB_dropboxImages li').each(function(){
      if($(this).hasClass('selected') && !$(this).hasClass('uploading')){
        totalImagesToUpdate++ // add another image to the count
        imagesSelected = true; // an image has been found!
        
        var selectedImageID = getImageIDFromURL($(this).find('img').attr('src'));
        var imageID = selectedImageID.split('-')[0];
        selectedImages.push(imageID);
      }
    });
    
    // Loop thru and remove imagery
    for(var u = 0; u < selectedImages.length; u++){
      $.ajax({
            url: "/images/" + selectedImages[u] + "/disable.json",
            type: 'POST',
            contentType: 'application/json',
            dataType: 'json',
            complete: checkImagesUpdates
        });
        
      /*$.post("/images/" + selectedImages[u] + "/disable.json",
        function(data) {
          log(data)
          alert('image removed');
      });*/
    }
  })
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
    $('#IB_dropboxCover').hide();
    passedImages = data[data.length-1].split(',');
  
    // These are the image ID's we recieved
    displayImages(passedImages);
  }
  
};

var selectAllImages = function(){
  // set all images to be selected by default
  $('#IB_dropboxImages li').each(function(){
    $(this).addClass('selected');
  });
  updateSelectedList();
}

var displayImages = function(images){
  // Request JSON
  $.getJSON("/images.json?ids=" + images.toString(),
    function(images) {
      for(var u = 0; u < images.length; u++){
        var newImage = '<li class="qq-upload-success"><img width="120" height="120" src="/images/uploads/' + images[u].id + '-126x126.' + images[u].format + '"></li>';
        $('#IB_dropboxImages').append(newImage);
      }
      
      resetImageSelectionEvents();
      
      selectAllImages();
    });
  
  // temp hack!
  // IF 1 image is loaded, grab its tags
  if(images.length == 1){
    // Get tags from image & set
    $.getJSON("/images/" + images[0] + ".json",
    function(data) {
      //alert("TAGS :: " + data.image.tags)
      var newTags = data.tags;
      $('.IB_managerTagInput').val(newTags);
      
    });
    
  }
}

var updateSelectedList = function(){
  currentSelectedImages = [];
  $('#IB_dropboxImages li').each(function(){
    if($(this).hasClass('selected') && !$(this).hasClass('uploading')){
      var selectedImageID = getImageIDFromURL($(this).find('img').attr('src'));
      //var selectedImageID = getImageIDFromURL($(this).find('img').attr('alt'));
      
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
  
  displaySelectedImageMetaData();
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
    }
  });
}


// Multi image meta-data handler
var currentSelectedImages = [];

var displaySelectedImageMetaData = function(){
  // Get images data
  if(currentSelectedImages == ''){
    // Empty all input's
    emptyAllFields();
  } else {
    var imageIDString = currentSelectedImages.toString();
  
    $.getJSON("/images.json?ids=" + imageIDString,
      function(images) {
        checkForSimilarMetaData(images);
        currentSelectedImages = [];
      });
  }
}

var removeAllImages = function(){
  $('#IB_dropboxImages').empty();
}

var emptyAllFields = function(){
  $('input').val('');
  $('textarea').val('')
  $('.IB_managerSourceCheckbox, .IB_managerInfoCheckbox').attr('checked', false);

  $('#IB_current_type, #IB_current_category, #IB_current_genre').html('Choose');
  $('#IB_typeList, #IB_categoryList, #IB_genreList').val('None');
}

var checkForSimilarMetaData = function(images){
  // create temp var
  var similarMetaData = {"album":"","artist":"","category":"","created_at":"","format":null,"genre":"","geotag":null,"id":null,"location":"","notes":"","public":null,"tags":null,"title":"","updated_at":"","uploaded_at":null,"uploaded_by":"","year":null};

  // check if it has more than 1 image
  if(images.length > 1){
    // First object
    var obj = images;
    
    // each param checks against all others
    for(param in obj[0]){
     var valuesMatch = true;
     var valueIndex = '';
     
     // Check for match OLD WAY
     for(var u = 1; u < images.length; u++){
      //alert("FOR :: " + param + " ::\n" + images[0][param] + ' / ' + images[u][param]);
      
      if(images[0][param] != images[u][param]){
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
      similarMetaData[param] = images[0][param];
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
  
  // Set the top display fields
  $('#IB_current_type').html(metadata.section);
  $('#IB_current_category').html(metadata.category);
  $('#IB_current_genre').html(metadata.genre);
  
  // Set the top dropdowns
  $('#IB_typeList').val(metadata.section)
  $('#IB_categoryList').val(metadata.category)
  
  // Must set the genreList dropdown options before
  // setting the dropdown state
  setGenreOptions()
  
  $('#IB_genreList').val(metadata.genre)
  
  
  
  // Set Meta Fields
  $('#IB_title_input').val(metadata.title);
  $('#IB_album_input').val(metadata.album);
  $('#IB_author_input').val(metadata.artist);
  $('#IB_location_input').val(metadata.location);
  $('#IB_year_input').val(metadata.year);
  $('#IB_notes_input').val(metadata.notes);
  $('#IB_date_input').val(metadata.created_at);
  $('#IB_user_input').val(metadata.uploaded_by);
  $('#IB_geotag_input').val(metadata.geotag);
  $('.IB_managerTagInput').val(metadata.tags);
  $('#IB_source_input').val(metadata.attribution);
}

// Check to make sure there are images selected
var imagesSelected = false;
var totalImagesToUpdate = 0;
var totalImagesUpdated = 0;

var updateCurrentImagesMeta = function(update){
  if($('#IB_current_genre').text() != 'Choose'){
    if(update == 'update'){
      // Set Save button to spinner
      $('#IB_managerSave').html('Saving');
      var newElement = '<div class="spinner" style="float: left; margin-left: 3px; margin-top: 3px; width: 32px; height: 32px"></div>';
      $('#IB_managerSave').prepend(newElement);
    
      // Collect data from fields for JSON
      collectParams();
  
      // Get currently selected images
      imagesSelected = false;
   
      $('#IB_dropboxImages li').each(function(){
        if($(this).hasClass('selected')){
          totalImagesToUpdate++ // add another image to the count
          imagesSelected = true; // an image has been found!
      
          // Get current ID
          var currentImageID = getIDFromUrl($(this).find('img').attr('src'));
      
          // Make call & set data
          $.ajax({
              url: "/images/" + currentImageID + ".json",
              type: 'PUT',
              contentType: 'application/json',
              data: JSON.stringify(imageMetaParams),
              dataType: 'json',
              complete: checkImagesUpdates2
          });
        }
      });
  
      if(!imagesSelected){
        // No Images were selected
        alert('No images selected.')
      }
    } else {
      // Set Save button to spinner
      $('#IB_managerSave').html('Saving');
      var newElement = '<div class="spinner" style="float: left; margin-left: 3px; margin-top: 3px; width: 32px; height: 32px"></div>';
      $('#IB_managerSave').prepend(newElement);
    
      // Collect data from fields for JSON
      collectParams();
  
      // Get currently selected images
      imagesSelected = false;
   
      $('#IB_dropboxImages li').each(function(){
        if($(this).hasClass('selected')){
          totalImagesToUpdate++ // add another image to the count
          imagesSelected = true; // an image has been found!
      
          // Get current ID
          var currentImageID = getIDFromUrl($(this).find('img').attr('src'));
      
          // Make call & set data
          $.ajax({
              url: "/images/" + currentImageID + ".json",
              type: 'PUT',
              contentType: 'application/json',
              data: JSON.stringify(imageMetaParams),
              dataType: 'json',
              complete: checkImagesUpdates
          });
        }
      });
  
      if(!imagesSelected){
        // No Images were selected
        alert('No images selected.')
      }
    }
  } else {
    alert('You must choose a Genre.')
  }
}

var checkImagesUpdates = function(XMLHttpRequest, textStatus){
  totalImagesUpdated++
  if(totalImagesToUpdate == totalImagesUpdated){
    alert('Images have been saved.');
    resetInterface();
  }
}

var checkImagesUpdates2 = function(XMLHttpRequest, textStatus){
  totalImagesUpdated++
  if(totalImagesToUpdate == totalImagesUpdated){
    alert('Images have been updated.');
    $('#IB_managerSave').html('Save');
    $('#IB_managerSave').unbind();
    $('#IB_managerSave').click(function(){
      updateCurrentImagesMeta();
    }) 
    //resetInterface();
  }
}

var resetInterface = function(){
  $('#IB_managerSave').html('Save');
  $('#IB_dropboxCover').fadeIn();
  emptyAllFields();
  removeAllImages();
  
  $('#IB_managerSave').unbind();
  $('#IB_managerSave').click(function(){
    updateCurrentImagesMeta();
  }) 
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
  
  if($('#IB_source_checkbox').attr("checked")){
    imageMetaParams.image.attribution =  $('#IB_source_input').val();
  }
}