var currentGenre = "";
var currentArtist = "";
var currentSlideshowImage = '';
var currentView = "browse"; // Changes to "search"

var viewingTopLevel = false;

// Maximum size of any image side in full-screen/slideshow mode
var maxImageSide = 700;

// Whatever this var is set to, is the section that the images will come from
// leave an empty var for all images from all sections.
var sectionFilter = 'Library';

var shuffleToggled = false;

// Data Objects
var imagesJSONContainer = {};
var slideshowJSONContainer = {};
var dropBoxJSONContainer = {};


// This is the path to the manager for
// switching between views.
var managerPath = "images/manage";


function getParameterByName( name ) {
  name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
  var regexS = "[\\?&]"+name+"=([^&#]*)";
  var regex = new RegExp( regexS );
  var results = regex.exec( window.location.href );
  if( results == null )
    return "";
  else
    return decodeURIComponent(results[1].replace(/\+/g, " "));
}


setGenre = function(genre) {
  currentGenre = genre;
  $("#IB_searchGenres li").each(function() {
    if ($(this).text() == genre) {
      $(this).addClass("selected");
    }
  });
};

setArtist = function(artist) {
  currentArtist = artist;
  $("#IB_search_artist").val(artist);
};

loadBrowse = function() {
  $(".uiMode").hide();
  
  currentView = "browse";
  currentGenre = "";
  currentArtist = "";
  
  //search options
  $("#IB_searchGenres li").removeClass("selected");
  $("#IB_search_artist").val("");
  
  $("#IB_searchOptionsButton, .browseBars").show();
  $("#IB_searchOptionsTab").hide();
  
  $("#IB_browseBack,#IB_browseArrow").hide();
  $("#IB_browse,#IB_category").show();
  $("#IB_category").text("Browse");
  /*$("#IB_browse li").unbind(); // moved to .nav-expand p
  $("#IB_browse li").click(function() {
    loadArtistList($(this).find('span').text());
  });*/
  
  var config = {
      over: function(){
        $(this).find('.nav-expand').fadeIn()
      },
      sensitivity: 20, 
      interval: 30,
      out: function(){
        $(this).find('.nav-expand').fadeOut()
      }
  }

  $('#IB_browse li').hoverIntent(config)
  $('#IB_browse li').find('.nav-expand p').unbind()
  $('#IB_browse li').find('.nav-expand p').click(function(){
    loadArtistList($(this).text())
  })
  $('#IB_browse li').find('span').unbind()
  $('#IB_browse li').find('span').click(function(){
    loadCategoryList($(this).text())
  })
    
};

closeSearchExpand = function(){
  $("#IB_searchBoxActive,#IB_searchBoxActiveWrap,#IB_browseBack,#IB_browseBackWrap").hide();
  $("#IB_searchBox,#IB_searchBoxWrap").show();
}
loadCategoryList = function(genre){
  viewingTopLevel = true;
  $(".uiMode,.browseBars").hide();
  
  setGenre(genre);
  $("#IB_browseArrow p").text("Browse");
  $("#IB_category").text(genre);
  $("#IB_browseArrow").click(loadBrowse);
  $("#IB_browseArrow").show();
  
  // setup slideshow button for whole genre
  /*$('#IB_artistSlideshow').unbind();
  $('#IB_artistSlideshow').click(function(){
    loadSlideshow(null, null, genre);
  });
  $('#IB_artistSlideshow').css('display', 'inline');*/
  

  // Populate Artists List
  $.get("/artists?category="+genre+"&section="+sectionFilter, function(artists) {
    // Clear list
    $("#artists").html($(artists).find('#artists').children());
    
    // Clean up search just in case
    closeSearchExpand();
    /*
    $.each(artists, function(artist, images) {
      // Only allow 6 max images
      var imageLength = (artist.length > 5) ? 6 : artist.length;
      
      var item = '<li><h2 class="color-0 font-H1 font-light">'+artist+'</h2>';
      if (images.length > 0) {
        item += "<div class=\"images\">";
        $.each(images, function(i, image) {
          // Get file path from results
          var filePath = '/images/uploads/' + image.id + '-62x62.' + image.format;
          
          var metaData = image.title+'|'+image.tags+'|'+image.artist+'|'+image.year;
          item += '<img alt="' + image.id + '" src="' + filePath + '"/>';
          //item += '<img class="albumPreviewThumbs" src="/images/art/IB_artistImages/artistImage2.jpg"/>';
        });
        item += "</div>";
      }
      item += "</li>";
      $("#artists").append(item);
      
      $('#artists .images img').click(function(event){
        //event.stopPropagation();
        //loadSlideshow($(this).attr('alt') + ',');
      })
    });
    */
    // A click on any image simply loads that artist's page.
    $("#artists li").click(function() {
      var artist = $("h2",this).text();
      $("#IB_search_artist").val(artist);
      loadArtist(artist);
    });  
  });
      
  $("#IB_artistContainer").fadeIn();
}
loadArtistList = function(genre) {
  viewingTopLevel = false;
  $(".uiMode,.browseBars").hide();
  
  setGenre(genre);
  $("#IB_browseArrow p").text("Browse");
  $("#IB_category").text(genre);
  $("#IB_browseArrow").click(loadBrowse);
  $("#IB_browseArrow").show();
  

  // Populate Artists List
  $.get("/artists?genre="+genre+"&section="+sectionFilter, function(artists) {
    // Clear list
    $("#artists").html($(artists).find('#artists').children());
    
    
    // Clean up search just in case
    closeSearchExpand();
    /*
    $.each(artists, function(artist, images) {
      // Only allow 6 max images
      var imageLength = (artist.length > 5) ? 6 : artist.length;
      
      var artistName;
      if(artist == ''){
        artistName = 'Unknown Artist';
      } else {
        artistName = artist
      }
      
      var item = '<li><h2 class="color-0 font-H1 font-light">'+artistName+'</h2>';
      if (images.length > 0) {
        item += "<div class=\"images\">";
        $.each(images, function(i, image) {
          // Get file path from results
          var filePath = '/images/uploads/' + image.id + '-62x62.' + image.format;
          
          var metaData = image.title+'|'+image.tags+'|'+image.artist+'|'+image.year;
          item += '<img alt="' + image.id + '" src="' + filePath + '"/>';
          //item += '<img class="albumPreviewThumbs" src="/images/art/IB_artistImages/artistImage2.jpg"/>';
        });
        item += "</div>";
      }
      item += "</li>";
      $("#artists").append(item);
      
      $('#artists .images img').click(function(event){
        //event.stopPropagation();
        //loadSlideshow($(this).attr('alt') + ',');
      })
    });
    */
    // A click on any image simply loads that artist's page.
    $("#artists li").click(function() {
      var artist = $("h2",this).text();
      
      if(artist == 'Unknown Artist'){
        artist = '';
      }
      
      $("#IB_search_artist").val(artist);
      loadArtist(artist);
    });  
  });
      
  $("#IB_artistContainer").fadeIn();
};

checkForEmptyDropbox = function(){
  if($('#IB_imageDrop').children().length < 1){
    $('#IB_searchResultsSelectEditWrap, #IB_searchResultsSelectCancelWrap, #IB_searchResultsSelectAddWrap').fadeOut();
  }
}

addImageToDropbox = function(imageId) {
  // Store image data in dropBoxJSONContainer
  /*$.getJSON("/images.json?ids=" +imageId,
    function(images) {
      //alert('results + ' + images[0].image)
      //alert("length :: " + dropBoxJSONContainer[0].length)
      //dropBoxJSONContainer.push(images[0].image);
    });*/
  
  //Only allow the image to be dropped once
  if ($("#IB_imageDrop img#dropped_"+imageId).length == 0) {
    var src = $("#image_"+imageId).attr("src");
    
    //TODO: instead of using the same image, use a different thumbnail with the right dimensions
    $("#IB_imageDrop").append('<li><div class="removeFromDropboxButton">-</div><img class="dropBoxThumb" id="dropped_'+imageId+'" src="'+src+'" /></li>');
    
    // setup remove button
    $('.removeFromDropboxButton').click(function(){
      var imageId = $(this).parent().find('img').attr("id").split("_")[1];
      removeImageFromDropbox(imageId);
    });
    
    // Hide background & show buttons
    $('#IB_searchResultsSelectEditWrap, #IB_searchResultsSelectCancelWrap, #IB_searchResultsSelectAddWrap').fadeIn();
    $('#IB_searchResultsSelectEdit').unbind();
    $('#IB_searchResultsSelectEdit').click(function(){
      editImages();
    });
    
    $('#IB_searchResultsSelectAdd').unbind();
    $('#IB_searchResultsSelectAdd').click(function(){
      // Add images to dream
      
      addImagesToDream(getSelectedImagesWithFormat());
    });
  
    $("#IB_searchResultsSelectCancel").unbind();
    $("#IB_searchResultsSelectCancel").click(function() {
      /*$("#IB_browseBack,#IB_searchBoxActive").hide();
      $("#IB_searchBox").show();
      loadBrowse();*/
      $('#IB_searchResultsSelectEditWrap, #IB_searchResultsSelectCancelWrap, #IB_searchResultsSelectAddWrap').fadeOut();
      // Empty the dropBox
      $('#IB_imageDrop').empty();
    });
    
    $('#IB_imageDrop').css('background', 'none');
  }
}

addImagesToDream = function(images){
  // Create image node for each image passed
  // image returns thumbnail w/ format
  for(var u = 0; u < images.length; u++){
    var newNode = '<div class="dreamImageContainer" style="width: 120px;"><div style="background: url(&quot;/images/uploads/' + images[u] + '&quot;) no-repeat center center transparent; width: 120px;" class="dreamImage round-8"><div class="imageRemoveButton dark O-bevel">X</div><textarea class="dreamImageCaption"></textarea></div></div>';
    
    $('#currentImages').prepend(newNode);
  }
  
  $('#IB_browser_frame').fadeOut('fast', function(){
    $(this).remove();
  });
  
  resetImageButtons();
  
  // show images
  $('#currentImages').fadeIn();
}

closeImagebank = function(){
  $('#IB_browser_frame').fadeOut('fast', function(){
    $(this).remove();
  });
}

removeImageFromDropbox = function(imageId){
  $("#IB_imageDrop li img").each(function(index, object){
    if($(this).attr('id').split("_")[1] == imageId){
      $(this).parent().remove();
      
      checkForEmptyDropbox();
      // Break callback loop
      return false;
    }
  });
}

addImageToDropboxSearch = function(imageId) {
  //Only allow the image to be dropped once
  if ($("#IB_searchResultsSelect img#dropped_"+imageId).length == 0) {
    var src = $("#image_"+imageId).attr("src");
    //TODO: instead of using the same image, use a different thumbnail with the right dimensions
    $("#IB_searchResultsSelect").append('<li><img class="dropBoxThumb" id="dropped_'+imageId+'" src="'+src+'" /></li>');
  }
}

var artistHolder = '';

loadArtist = function(artist) {
  closeSearchExpand();
  $(".uiMode").hide();
  artistHolder = artist;
  
  setArtist(artist);
  $("#IB_browseArrow p").text(currentGenre);
  $("#IB_category").text(artist);
  
  $('#IB_browseArrow').show();
  $("#IB_browseArrow").unbind();
  $("#IB_browseArrow").click(function() {
    // clear albums list
    $('#albums').empty();
    if(!viewingTopLevel){
      loadArtistList(currentGenre);
    } else {
      loadCategoryList(currentGenre);
    }
  });
  
  // Check to see if there are dropbox images
  // If so, show the buttons on the right & hide BG
  if($('#IB_imageDrop li').length > 0){
    $('#IB_searchResultsSelectEditWrap, #IB_searchResultsSelectCancelWrap, #IB_searchResultsSelectAddWrap').show();
    $('#IB_searchResultsSelectEdit').unbind();
    $('#IB_searchResultsSelectEdit').click(function(){
      editImages();
    });
  
    $("#IB_searchResultsSelectCancel").unbind();
    $("#IB_searchResultsSelectCancel").click(function() {
      $("#IB_browseBack,#IB_searchBoxActive").hide();
      $("#IB_searchBox").show();
      loadBrowse();
    
      // Empty the dropBox
      $('#IB_imageDrop').empty();
    });
    
    $('#IB_imageDrop').css('background', 'none');
  } else {
    $('#IB_searchResultsSelectEditWrapop').css('background', 'url("../images/icons/dropboxIconText.png") no-repeat scroll 295px center #272727');
    $('#IB_searchResultsSelectEditWrap, #IB_searchResultsSelectCancelWrap, #IB_searchResultsSelectAddWrap').hide();
  }
  
  
  
  getImages = function(root) {
    var images = "";
    /*$("#albums .selected").each(function() {
      images += $("img",$(this).parent()).attr("src")+",";
    });*/
    $("img",root).each(function() {
      images += $(this).attr("id").replace("image_","")+",";
    });
    
    if (images.length > 0) {
      images = images.substring(0,images.length-1);
    }
    return images;
  };
  getImagesDropBox = function(root) {
    var images = [];
    
    $("img",root).each(function() {
      var tempVal = $(this).attr("src").replace("/images/uploads/","")+",";
      var tempVal2 = tempVal.split('.');
      images.push(tempVal2[0]);
    });
    
    return images;
  };
  getImagesDropBoxFormat = function(root) {
    var images = [];
    
    $("img",root).each(function() {
      var tempVal = $(this).attr("src").replace("/images/uploads/","");
      images.push(tempVal);
      
    });
    
    return images;
  };
  getAllImages = function() {
    return getImages($("#albums")); 
  };
  getSelectedImages = function() {
    return getImagesDropBox($("#IB_imageDrop"));
  };
  
  getSelectedImagesWithFormat = function() {
    return getImagesDropBoxFormat($("#IB_imageDrop"));
  };
  
  populateAlbums = function(albums) {
    $("#albums").html($(albums).find('#albums').children());
    
    // Make the + icon clickable
    $('.images > li > .addToDropboxButton').click(function(){
      var imageId = $(this).parent().find('img').attr("id").split("_")[1];
      addImageToDropbox(imageId);
    });
    
    // Make the thumbnails clickable to slideshow.
    // contain all current images in this album in slideshow
    $('.images > li > img').click(function(){
      if(!isDragging){
        var clickedImageID = $(this).attr('id').split("_")[1];
        var currentAlbumIDs = '';
    
        $(this).parent().parent().find('li > img').each(function(){
          currentAlbumIDs += $(this).attr('id').split("_")[1];
        })
        // Pass special param to show index of current image $(this).index
        loadSlideshow(getImages($(this).parent().parent()), $(this).parent().index());
      }
    })

    //Make images draggable to the drop-box below.
    $(".images li").draggable({
      containment: 'document',
      helper: 'clone',
      appendTo: '#imageDrop',
      zIndex:10000,
      distance: 40,
      scroll: false,
      revert: false,
      start: function(event, ui) {
        isDragging = true;
      },
      stop: function(event, ui) {
        isDragging = false;
      }
    });
    
    // Set up header manage
    $('.header-manage').click(function(event){
      event.stopPropagation();
      
      var tempString = '';
      
      $(this).parent().next().find('li img').each(function(index, element){
        if(index == 0){
          tempString += $(this).attr('id').split("_")[1];
        } else {
          tempString += "," + $(this).attr('id').split("_")[1];
        }
        
      });
      
      // Go-to manage page
      window.location.href = managerPath + "?images=" + tempString;
    })
    
    // Set up manage on TOP BAR
    $('#IB_manageArtistImages').unbind();
    $('#IB_manageArtistImages').click(function(){
      // get all images by artist
      var imageIDCollector = '';
      $('#albums ul.images img.albumPreviewThumbsLarger').each(function(index, element){
        if(index == 0){
          imageIDCollector = $(this).attr('id').split("_")[1];
        } else {
          imageIDCollector += ',' + $(this).attr('id').split("_")[1];
        }
      });
      
      // Go-to manage page
      window.location.href = managerPath + "?images=" + imageIDCollector;
    });
    
    // Slideshow 
    $('#IB_artistSlideshow').unbind();
    $('#IB_artistSlideshow').click(function(){
      // get all images by artist
      var imageIDCollector = '';
      $('#albums ul.images img.albumPreviewThumbsLarger').each(function(index, element){
        if(index == 0){
          imageIDCollector = $(this).attr('id').split("_")[1];
        } else {
          imageIDCollector += ',' + $(this).attr('id').split("_")[1];
        }
      });
      
      // Start Slideshow
      loadSlideshow(imageIDCollector);
    });

    // Show manage/slideshow buttons
    $('#IB_manageArtistImages').show();
    $('#IB_artistSlideshow').show();
    
    /*$.each(albums, function(i, value){
      var albumName;
      if(i == null){
        albumName = 'Unknown Album';
      } else {
        albumName = i;
      }
      
      $("#albums").append('<li><h2 class="gradient-10-up">'+albumName+'<img class="header-manage" src="../images/icons/edit-23.png" /></h2></li>');
    })*/

    /*
    $("#albums > li").each(function() {
      var album;
      if($("h2",this).text() == "Unknown Album"){
        album = "null";
      } else {
        album = $("h2",this).text();
      }
      
      var element = $(this);
      $.getJSON("/images.json?artist="+artist+"&album="+album+"&section="+sectionFilter+"&genre="+currentGenre,
        function(images) {
          if (images.length > 0) {
            item = '<ul class="clearfix images">';
            for (j = 0; j < images.length; j++)
            {
              var image = images[j];
              
              // Get file path from results
              var filePath = '/images/uploads/' + image.id + '-126x126.' + image.format;
          
              var metaData = image.title+'|'+image.tags+'|'+image.artist+'|'+image.year;
              //TODO: Meta-data currently stored in alt attribute (could be moved to hidden input)
              
              item += '<li><div class="addToDropboxButton">+</div><img class="albumPreviewThumbsLarger" id="image_'+image.id+'" src="' + filePath + '" alt="'+metaData+'" /></li>';
            }
            item += "</ul>";
            element.append(item);
            
            // Make the + icon clickable
            $('.images > li > .addToDropboxButton').click(function(){
              var imageId = $(this).parent().find('img').attr("id").split("_")[1];
              addImageToDropbox(imageId);
            });
            
            // Make the thumbnails clickable to slideshow.
            // contain all current images in this album in slideshow
            $('.images > li > img').click(function(){
              if(!isDragging){
                var clickedImageID = $(this).attr('id').split("_")[1];
                var currentAlbumIDs = '';
            
                $(this).parent().parent().find('li > img').each(function(){
                  currentAlbumIDs += $(this).attr('id').split("_")[1];
                })
                // Pass special param to show index of current image $(this).index
                loadSlideshow(getImages($(this).parent().parent()), $(this).parent().index());
              }
            })

            //Make images draggable to the drop-box below.
            $(".images li",element).draggable({
              containment: 'document',
              helper: 'clone',
              appendTo: '#imageDrop',
              zIndex:10000,
              distance: 40,
              scroll: false,
              revert: false,
              start: function(event, ui) {
                isDragging = true;
              },
              stop: function(event, ui) {
                isDragging = false;
              }
            });
            
            // Set up header manage
            $('.header-manage').click(function(event){
              event.stopPropagation();
              
              var tempString = '';
              
              $(this).parent().next().find('li img').each(function(index, element){
                if(index == 0){
                  tempString += $(this).attr('id').split("_")[1];
                } else {
                  tempString += "," + $(this).attr('id').split("_")[1];
                }
                
              });
              
              // Go-to manage page
              window.location.href = managerPath + "?images=" + tempString;
            })
            
            // Set up manage on TOP BAR
            $('#IB_manageArtistImages').unbind();
            $('#IB_manageArtistImages').click(function(){
              // get all images by artist
              var imageIDCollector = '';
              $('#albums ul.images img.albumPreviewThumbsLarger').each(function(index, element){
                if(index == 0){
                  imageIDCollector = $(this).attr('id').split("_")[1];
                } else {
                  imageIDCollector += ',' + $(this).attr('id').split("_")[1];
                }
              });
              
              // Go-to manage page
              window.location.href = managerPath + "?images=" + imageIDCollector;
            });
            
            // Slideshow 
            $('#IB_artistSlideshow').unbind();
            $('#IB_artistSlideshow').click(function(){
              // get all images by artist
              var imageIDCollector = '';
              $('#albums ul.images img.albumPreviewThumbsLarger').each(function(index, element){
                if(index == 0){
                  imageIDCollector = $(this).attr('id').split("_")[1];
                } else {
                  imageIDCollector += ',' + $(this).attr('id').split("_")[1];
                }
              });
              
              // Start Slideshow
              loadSlideshow(imageIDCollector);
            });
    
            // Show manage/slideshow buttons
            $('#IB_manageArtistImages').show();
            $('#IB_artistSlideshow').show();
            
          } else {
            // No images, hide album
            //element.hide();
          }
        }
      );
    });*/
    
    $('#albums > li > h2').click(function(){
      // Start slideshow on header click
      loadSlideshow(getImages($(this).next()));
      //window.location.href = managerPath + "?images=" + getImages($(this).next());
    });
    
    
    
    $('.IB_Cancel').unbind();
    $('.IB_Cancel').click(function(){
      loadArtistList(currentGenre);
    });
    
    //$("#IB_searchResultsSelectBar").show();

    $("#IB_imageDrop").droppable({
      drop: function(event, ui) {
        var imageId = $("img",ui.draggable).attr("id").split("_")[1];
        addImageToDropbox(imageId);
      }
    });
  };
  if(viewingTopLevel){
    $.get("/albums?artist="+artist+"&section="+sectionFilter+"&category="+currentGenre,
        function(albums) {
          populateAlbums(albums);
        }
      );
  } else {
    $.get("/albums?artist="+artist+"&section="+sectionFilter+"&genre="+currentGenre,
        function(albums) {
          populateAlbums(albums);
        }
      );
  }
  
  $("#IB_manageArtistImages").unbind();
  $("#IB_manageArtistImages").click(function() {
    window.location.href = managerPath + "?images="+getSelectedImages();
  });
  
  $("#IB_artistSlideshow").unbind();
  $("#IB_artistSlideshow").click(function() {
    // Changed from getAllImages() to getSelectedImages()
    // need to think about this
    
    if($('#IB_imageDrop li').length > 0){
     loadSlideshow(getSelectedImages()); 
    } else {
      alert('You have no images in your Dropbox.');
    }
  });
  
  $("#IB_albumContainer").fadeIn();
};




var currentItem;
var keyCaptured = false;


loadSlideshow = function(newImageIds, currentIndex, genre) {
  if(newImageIds == null && currentIndex == null){
    // Genre level slideshow, get all imageID's from genre
  }
  if ( currentIndex === undefined ) {
      currentIndex = 0;
   }
   
   $(document).keyup(function (e) { 
    }).keydown(function (e) { 
      //if(e.which == 17) isCtrl=true; 
      if(!keyCaptured){
        keyCaptured = true;
        if(e.which == 37) { // && isCtrl == true
          showPreviousImage();
          return false; 
        } else if(e.which == 39){// && isCtrl == true
          showNextImage();
          return false;
        }
      }
    });

  // Hide & clean up elements
  $(".uiMode,#IB_footerSet").hide();
  $('#IB_slideshow').empty();
  
  // Setup buttons
  $("#IB_browseArrow p").text(currentArtist);
  $("#IB_browseArrow").unbind();
  $("#IB_browseArrow").click(function() {
    // Just hide & show the last section
    // do not reload
    $(".uiMode").hide();
    
    setArtist(artistHolder);
    $("#IB_browseArrow p").text(currentGenre);
    $("#IB_category").text(artistHolder);
  
    $("#IB_browseArrow").unbind();
    $("#IB_browseArrow").click(function() {
      loadArtistList(currentGenre);
    });
    
    // Show manage/slideshow buttons
    $('#IB_manageArtistImages').show();
    $('#IB_artistSlideshow').show();
  
    $('#IB_albumContainer').show();
    //loadArtist(currentArtist);
  });
  
  $('#IB_footerAddDropWrap').unbind();
  $('#IB_footerAddDropWrap').click(function(){
    addImageToDropbox(currentSlideshowImage);
    loadArtist(currentArtist);
  });
  
  $('#IB_footerCancel').unbind();
  $('#IB_footerCancel').click(function(){
    loadArtist(currentArtist);
  });
  
  // Setup Slideshow
  $("#IB_category").text("Slideshow");
  var imageIds = [];
  imageIds = String(newImageIds).split(",");

  // NEW WAY - Store all images Obj's in slideshowJSONContainer
  //var imageIDString = imageIds.toString();
  
  // OLD WAY - Loop thru imageIds array and load images
  // into the IB_slideshow
  for (i = 0; i < imageIds.length; i++) {
    var imageElement = $("#image_"+imageIds[i]);
    
    // Get the new file path from the info we have. find format from old fileName
    var oldPath = imageElement.attr('src').split('.');
    var filePath = 'images/uploads/originals/' + imageIds[i] + '.' + oldPath[oldPath.length-1];
    
    //TODO - look for high-resolution instead of reusing thumbnail (was 750px / 766px)
    $("#IB_slideshow").append('<img id="slideshow_' + imageIds[i] +'" src="' + filePath + '" />');
  }
  $("#IB_slideshow img").hide();
  
  getCurrentImageId = function() {
    return $("#IB_slideshow img").eq(currentItem).attr("id").split("_")[1];
  };
  
  updateImageMetaData = function() {
    var imageId = getCurrentImageId();
    //alert(imageId);
    var imageElement = $("#image_"+imageId);
    //alert(imageElement.html());
    var metaData = imageElement.attr("alt").split("|");
    
    // Setup INFO panel
    $("#IB_category").text("Slideshow: "+metaData[0]);
  
    $('#IB_info_title span').text(metaData[0]);
    $("#IB_info_author span").text(metaData[2]);
    $("#IB_info_year span").text(metaData[3]);

    /*var tags = metaData[1].split(",");
    $("#tags").html("");
    for(i = 0; i < tags.length; i++) {
      $("#tags").append('<li>'+tags[i]+'</li>');  
    }*/
  };

  currentItem = currentIndex;
  var numberOfItems = imageIds.length;
  
  hideCurrentImage = function() {
    $("#IB_slideshow img").eq(currentItem).hide();
  };
  showCurrentImage = function() {
    $("#IB_footerAddDrop").css('border', '1px solid #333');
    $("#IB_footerAddDrop span").html('Add to Collection');
    // Turn off keyboard shortcut handler
    setTimeout(function() { keyCaptured = false; }, 100);
    
    currentSlideshowImage = getCurrentImageId();
    
    getCurrentImageTags();
    
    var currentImg = $("#IB_slideshow img").eq(currentItem);
    
    currentImg.unbind();
    currentImg.click(function(){
      showNextImage();
    }).css('cursor', 'pointer');
    
    currentImg.fadeIn();
    $("#IB_slideshowCount").text((currentItem+1)+"/"+numberOfItems);
    updateImageMetaData();
    
    setTimeout(function(){checkImageResize(currentImg);}, 200);
    
  };
  showPreviousImage = function() {
    hideCurrentImage();
    
    if(!shuffleToggled){
      // Shuffle is off play normal order
      if (currentItem == 0) {
        currentItem = numberOfItems - 1;
      } else {
        currentItem--;
      }
    } else {
      // Shuffle is on play random order
      var randomnumber = Math.floor(Math.random()*(numberOfItems - 1))
      
      if(randomnumber == currentItem){
        if(randomnumber == numberOfItems - 1){
          randomnumber = 0;
        } else if(randomnumber == 0){
          randomnumber++;
        }
      }
      currentItem = randomnumber;
    }
    showCurrentImage();
  };
  showNextImage = function() {
    hideCurrentImage();
    if(!shuffleToggled){
      // Shuffle is off play normal order
      if (currentItem == numberOfItems - 1) {
        currentItem = 0;
      } else {
        currentItem++;
      }
    } else {
      // Shuffle is on play random order
      var randomnumber = Math.floor(Math.random()*(numberOfItems - 1))
      
      if(randomnumber == currentItem){
        if(randomnumber == numberOfItems - 1){
          randomnumber = 0;
        } else if(randomnumber == 0){
          randomnumber++;
        }
      }
      currentItem = randomnumber;
    }
    showCurrentImage();
  };
  
  // Setup buttons
  $("#IB_prevWrap").unbind();
  $("#IB_prevWrap").click(function(){
    showPreviousImage();
  });
  
  $("#IB_nextWrap").unbind();
  $("#IB_nextWrap").click(function(){
    showNextImage();
  });
  
  // Display the current image
  showCurrentImage();
  
  if(sectionFilter == "Bedsheets"){
    $("#IB_footerSet").unbind();
    $("#IB_footerSet").click(function() {
      // Send code back to DC to set THIS as the bedsheet
    });
   $("#IB_footerSet").show(); 
  }
  
  
  $("#IB_footerAddDrop").unbind();
  $("#IB_footerAddDrop").click(function() {
    var imageId = getCurrentImageId();
    addImageToDropbox(imageId);
    
    $("#IB_footerAddDrop").css('border', '1px solid #fff');
    $("#IB_footerAddDrop span").html('Added');
  });
  
  $("#IB_footer .tag").unbind();
  $("#IB_footer .tag").click(function() {
    if ($("#IB_tagContainer").is(":visible")) {
      $(this).css('background', 'url(../images/icons/tag-25.png) no-repeat center');
      $("#IB_tagContainer").slideUp();
    } else {
      $(this).css('background', 'url(../images/icons/tag-25-selected.png) no-repeat center');
      $("#IB_tagContainer").slideDown();
    }
  });
  
  $('#IB_footer .info').unbind();
  $('#IB_footer .info').click(function(){
    if ($("#IB_infoContainer").is(":visible")) {
      $(this).css('background', 'url(../images/icons/info-25.png) no-repeat center')
      $("#IB_infoContainer").slideUp();
    } else {
      $(this).css('background', 'url(../images/icons/info-25-selected.png) no-repeat center')
      $("#IB_infoContainer").slideDown();
    }
  })
  
  
  $('#IB_footer .fullscreen').unbind();
  $('#IB_footer .fullscreen').click(function(){
    openFullscreen();
  })
  
  $("#IB_footer .shuffle").unbind();
  $("#IB_footer .shuffle").click(function() {
    if (!shuffleToggled) {
      $(this).css('background', 'url(../images/icons/shuffle-26-selected.png) no-repeat center');
      shuffleToggled = true;
    } else {
      $(this).css('background', 'url(../images/icons/shuffle-26.png) no-repeat center');
      shuffleToggled = false;
    }
  });
  
  $('#IB_slideshow').slideDown();  
  $(".slideshow,#IB_footer").fadeIn();
  
  // Setup Timer functionality
  $('#IB_slideshowTimer').click(timerToggle);

}

timerToggle = function(event){
  // Toggle the timer value
  if($('#IB_slideshowTimer').text() == "20"){
    $('#IB_slideshowTimer').text("30");
  } else if($('#IB_slideshowTimer').text() == "30"){
    $('#IB_slideshowTimer').text("5");
  } else if($('#IB_slideshowTimer').text() == "5"){
    $('#IB_slideshowTimer').text("20");
  }
}

openFullscreen = function(){
  var currentImg = $("#IB_slideshow img").eq(currentItem);
  
  var tempCover = '<div id="full-screen"><img id="full-screen-image" src="' + currentImg.attr('src') + '" /></div>';
  $('body').append(tempCover);
  $('#full-screen').addClass('full-screen');
  $('#full-screen').hide();
  $('#full-screen-image').css('margin-top', window.pageYOffset);
  
  checkImageResize($('#full-screen-image'));
  
  $('#full-screen').fadeIn('fast');
  
  $('#full-screen').click(function(){
    $(this).fadeOut('fast', function(){
      $(this).remove();
    });
  })
}

checkImageResize = function(currentImg){
  // Check size todo :: needs work!
  //var currentImg = $("#IB_slideshow img").eq(currentItem);
  
  if(currentImg.attr('width') > maxImageSide){
    // Resize the image so its largest side is equal to maxImageSide
    if(currentImg.width() > currentImg.height()) { 
      currentImg.css('width',maxImageSide+'px');
      currentImg.css('height','auto');
    } else {
      currentImg.css('height',maxImageSide+'px');
      currentImg.css('width','auto');
    }
  }
}

loadSearch = function() {
  $("#IB_category,#IB_browseArrow,#IB_searchBox,.artist,#IB_searchBoxWrap,#IB_slideshowTimer,#IB_slideshowCount,.browseBars").hide();
  $("#IB_browseBack,#IB_browseBackWrap,#IB_searchBoxActive,#IB_searchBoxActiveWrap").show();
  
  $("#IB_browseBack").unbind();
  $("#IB_browseBack").click(function() {
    closeSearchExpand();
    loadBrowse();
  });
  $("#IB_searchText").focus(function() {
    // Setup ENTER to submit
    $('#IB_searchText').keyup(function(e) {
      if(e.keyCode == 13) {
        // Send data 
        loadSearchResults();
      }
    });
    if ($(this).val() == "search") {
      $(this).val("");
    }
  });
  $("#IB_searchText").blur(function() {
    // Remove ENTER listener
    $('#IB_searchText').keyup(function(){});
    if ($(this).val() == "") {
      $(this).val("search");
    }
  });
  $("#IB_searchOptionsButton").click(function() {
    $(this).hide();
    $("#IB_searchOptionsTab").show();
    loadSearchOptions();
  });
  $("#IB_searchOptionsTab").click(function() {
    hideSearchOptions();
  });
  $("#IB_searchBoxActive img").unbind();
  $("#IB_searchBoxActive img").click(function() {
    loadSearchResults();
  });
  $("#IB_searchResultsSelectCancel").unbind();
  $("#IB_searchResultsSelectCancel").click(function() {
    $("#IB_browseBack,#IB_searchBoxActive").hide();
    $("#IB_searchBox").show();
    loadBrowse();
  });
  $('#IB_searchResultsSelectEdit').unbind();
  $('#IB_searchResultsSelectEdit').click(function(){
    editSearchImages();
  });
};

var currentSelectedImages = [];

editImages = function() {
  $('#IB_imageDrop li > img').each(function(){
    currentSelectedImages.push($(this).attr('id').split("_")[1]);
  });
  
  window.location.href = managerPath + "?images=" + currentSelectedImages;
}

editSearchImages = function() {
  $('#IB_searchResultsSelect li > img').each(function(){
    currentSelectedImages.push($(this).attr('id').split("_")[1]);
  });
  
  window.location.href = managerPath + "?images=" + currentSelectedImages;
}

loadSearchOptions = function() {
  $(".uiMode").hide();
  $("#IB_searchOptions,#IB_searchFiltersContainer,#IB_searchGenresContainer,#IB_searchButton").show();
  
  // Category Dropdown Settings
  $('#IB_searchCategoryList > li > ul > li').click(function(){
    $('#IB_searchCategoryList > li > span').html($(this).html());
  });
  
  // Size Dropdown Settings
  $('#IB_searchSizeList > li > ul > li').click(function(){
    $('#IB_searchSizeList > li > span').html($(this).html());
  })
  
  // make value change
  $('.searchdrop').change(function(){
    $(this).parent().find('span').text($("option:selected", this).val());
  })
  
  $("#IB_searchGenres li").click(function() {
    if ($(this).hasClass("selected")) {
      $(this).removeClass("selected");
    } else {
      $(this).addClass("selected");
    }
  });
  $("#IB_searchButton").click(function() {
    loadSearchResults();
  });

}

hideSearchOptions = function() {
  showLast();
  
  $("#IB_searchOptions,#IB_searchFiltersContainer,#IB_searchGenresContainer,#IB_searchButton").hide();
  $("#IB_searchOptionsTab").hide();
  $("#IB_searchOptionsButton").show();
}

showLast = function() {
  // Shows the last section
  switch(currentView){
    case "browse":
      loadBrowse();
      $('#IB_category').hide();
      $('#IB_browseBack').show();
      break;
    
    case "search":
      $("#IB_searchImageResultsContainer, #IB_searchResultsSelectBar").show();
      
      break;
  }
}

var isDragging = false;

loadSearchResults = function() {
  currentView = "search";
  $(".uiMode").hide();
  $("#IB_searchOptionsButton").show();
  $("#IB_searchOptionsTab").hide();

  getSearchQueryString = function(field,value) {
    if (value == null || value.trim().length == 0) {
      return "";
    }
    return field+"="+value+"&";
  }
  
  var queryString = "";
  //TODO: Category and Size drop-downs
  //TODO: API Method needs to be written that handles this (this may need to be rewritten accordingly)
  
  //var category = $("#IB_search_category").val();
  //var size = $("#IB_search_size").val();
  queryString += getSearchQueryString("artist",$("#IB_search_artist").val());
  queryString += getSearchQueryString("title",$("#IB_search_title").val());
  queryString += getSearchQueryString("year",$("#IB_search_year").val());
  queryString += getSearchQueryString("tags",$("#IB_search_tag").val());
  
  // Check if search hasnt been edited
  if($('#IB_searchText').val() != "search"){
    queryString += getSearchQueryString("q", $("#IB_searchText").val())
  }
  
  var genres = "";
  $("#IB_searchGenres li.selected").each(function() {
    genres += $(this).text()+",";
  });
  if (genres.length > 0) {
    genres = genres.substring(0,genres.length-1);
  }
  queryString += getSearchQueryString("genre",genres);
  
  if (queryString.length > 0) {
    queryString = queryString.substring(0,queryString.length-1);
  }
  
  $("#IB_searchOptions,#IB_searchFiltersContainer,#IB_searchGenresContainer,#IB_searchButton").hide();
  
  
  
  // SEARCH
  $.getJSON("/images.json?"+queryString+"&section="+sectionFilter,
    function(images) {
      if (images.length > 0) {
        var element = $('#IB_searchImageResults');
        var item = '';
        
        element.empty();
        
        for (j = 0; j < images.length; j++)
        {
          var image = images[j].image;
              
          // Get file path from results
          var filePath = '/images/uploads/' + image.id + '-126x126.' + image.format;
          var metaData = image.title+'|'+image.tags+'|'+image.artist+'|'+image.year;
          
          //TODO: Meta-data currently stored in alt attribute (could be moved to hidden input)
          item += '<li><div class="addToDropboxButton">+</div><img class="albumPreviewThumbsLarger" id="image_'+image.id+'" src="' + filePath + '" alt="'+metaData+'" /></li>';
        }
        
        element.append(item);
      
        // Make the + icon clickable
        $('.images > li > .addToDropboxButton').click(function(){
          var imageId = $(this).parent().find('img').attr("id").split("_")[1];
          addImageToDropboxSearch(imageId);
        });
        
        // Make the thumbnails clickable to slideshow.
        // contain all current images in this album in slideshow
        $('.images > li > img').click(function(){
          if(!isDragging){
            var clickedImageID = $(this).attr('id').split("_")[1];
            loadSlideshow(clickedImageID);
          }
        })

        //Make images draggable to the drop-box below.
        $(".images li").draggable({
          containment: 'document',
          helper: 'clone',
          zIndex:10000,
          distance: 40,
          scroll: false,
          revert: true,
          start: function(event, ui) {
            isDragging = true;
          },
          stop: function(event, ui) {
            isDragging = false;
          }
        });
        $("#IB_searchResultsSelectBar").droppable({
          drop: function(event, ui) {
            var imageId = $("img",ui.draggable).attr("id").split("_")[1];
            addImageToDropboxSearch(imageId);
          }
        });
      }
      /*// Empty Old Search Results
      $('#IB_searchImageResults').empty();
      
      // Display new results
      for(i = 0; i < images.length; i++) { 
        $("#IB_searchImageResults").append("<li id=\"" + images[i].image.id + "\"><img class='searchThumbs' src=\"/images/uploads/"+images[i].image.id+".jpg\" /></li>");
      }
      
      // Setup click events
      $('#IB_searchImageResults li').unbind();
      $('#IB_searchImageResults li').click(function(event){
        selectImageNode($(this));
      })*/
    });
  
  $("#IB_searchImageResultsContainer,#IB_searchResultsSelectBar").show();
  
};

selectImageNode = function(selectedNode) {
  selectedNode.addClass('selected');
  $('#IB_searchResultsSelect').append(selectedNode);
  
  selectedNode.click(function(event){
    removeSelectedNode($(this));
  })
}

removeSelectedNode = function(selectedNode) {
  selectedNode.removeClass('selected');
  $('#IB_searchImageResults').append(selectedNode);
  
  selectedNode.click(function(event){
    selectImageNode($(this));
  })
}

getQueryValue = function(name,defaultValue) {
  var returnValue = getParameterByName(name);
  if (returnValue == null || returnValue.trim() == "") {
    return defaultValue;
  }
  return returnValue;
}







//************************************//
//            TAG HANDLING            //
//************************************//

//*********** ADDING TAGS ***********//

// Initialize Tag Entry Buttons

function initialize_addTag_button(buttonIdd, inputIdd, tagType) {     
  // When click '+ Follow *add* tag'
  //alert('add tag')
  $(buttonIdd).click(function() {
    //alert('clicked : ' + $(inputIdd).val() + ' / ' + $('#IB_tagText').val())
    addTagToList( $(inputIdd).val(), tagType, inputIdd );
  }); 

  $(inputIdd).keypress(function (e) {
    if (e.which == 13){
     addTagToList( $(inputIdd).val(), tagType, inputIdd );
    }
    activateRemoveTag('.tag_box');
  });

}
      
        
// ADDS DATA TO TAG LIST
function addTagToList(tagToAdd,tagType,tagInputBoxIdd){
  //alert("addTagToList() " + tagToAdd)
  var tag_selected =  tagToAdd; // set selected city to be the same as contents of the selected city
  var tag_type =  tagType; // type of tag (tag/thread/emotion/place/person/etc.)

  var randomNumber = Math.round( Math.random() * 100001) ; // Generate ID
  var tagID = 'tagID_' + randomNumber ; // Define ID for New Region
  var tagID_element = '#' + tagID ; // Create variable to handle the ID
  
  if (tag_selected != ''){ // if it's not empty
    $('#empty-tag').clone().attr('id', tagID ).appendTo('#tag-list').end; // clone tempty tag box
    $(tagID_element).removeClass('hidden') ; // and unhide the new one
    $(tagID_element).addClass('current-tags');
    $(tagID_element).contents().find('.tag-icon').addClass( tag_type ); // populate with tag icon
    $(tagID_element).contents().find('.content').html( tag_selected ); // populate with tag text
    
    $(tagID_element).css('background-color', '#ccc');
    setTimeout(function() { $(tagID_element).animate({ backgroundColor: "#333" }, 'slow'); }, 200);
    
    
  }
  
  
  $(tagInputBoxIdd).val(''); // Clear textbox
  $(tagInputBoxIdd).focus(); // Focus text input
  
  //$(tagInputBoxIdd).autocomplete( 'close' );
  
  activateRemoveTag('.tag_box');
  
  // Update on server
  if(tagInputBoxIdd == "#IB_tagText"){
    updateCurrentImageTags();
  }
  
  //$(tagID_element).addClass('tag_box_pop', 1000);
  
  return false;
    
            
 };


//*********** REMOVING TAGS ***********//  

function activateRemoveTag (context) {
  $(context).mouseup(function() {
    //alert('this :: ' + $('#sorting').val())
    if ($("#sorting").val() == 0)
      removeTagFromList(this);
  }); 
  
}

$(function() {
  
  activateRemoveTag('.tag_box');

});

// REMOVES DATA FROM TAG LIST          
function removeTagFromList (idd){
  
  //$(idd).removeClass('tag_box', 0 );
  $(idd).addClass('kill_tag');
  
  setTimeout(function() { $(idd).addClass('opacity-50', 0 ); }, 250);
  setTimeout(function() { $(idd).fadeOut('fast'); }, 300);
  
  updateCurrentImageTags();

};
  
function updateCurrentImageTags(){
  // Gets the tags from the list, and sets them on the server
  var tempTagString = '';
  $('.current-tags').each(function(index, element){
    if(index == 0){
      // No comma for first one
      tempTagString += $(this).find('.content').text();
    } else {
      // add comma & next tag
      tempTagString += ", " + $(this).find('.content').text();
    }
  })

  // create JSON obj to pass to server
  var imageTagMeta = { image: {} };
  imageTagMeta.image.tags = tempTagString;
  
  // Make call & set data
  $.ajax({
      url: "/images/" + currentSlideshowImage + ".json",
      type: 'PUT',
      contentType: 'application/json',
      data: JSON.stringify(imageTagMeta),
      dataType: 'json',
      success: function(data) {
        $('#emptyMessage').html(data);
        alert('Load was performed.');
      }

  });
      
}

function getCurrentImageTags(){
  // Gets the current images tags from the server & displays
  $.getJSON("/images/" + currentSlideshowImage + ".json",
    function(artists) {
      // Empty old tags
      //$('#tag-list').empty();
      $('.current-tags').remove();
      $('#emptyMessage').empty();
      
      if(typeof(artists.tags) != "object"){
        // Temp array
        var tagArray = artists.tags.split(',');
        for(var u = 0; u < tagArray.length; u++){
          addTagToList(tagArray[u]);
        }
      } else {
        // Empty Tags
        $('#emptyMessage').html('<p style="color: #fff; font-weight: bold;">There are currently no tags for this image</p>')
      }
    });
}

var checkForParams = function(){
  var query = window.location.search;
  if (query.substring(0, 1) == '?') {
    query = query.substring(1);
  }
  var queryString = '';
  var queryValue = '';
  
  var data = query.split('=');
  if(data[0] == ""){
    // EMPTY
  } else {
    queryString = data[0]
    queryValue = data[1];
    
    switch(queryString){
      case "search":
        loadSearch();
        
        $("#IB_searchOptionsButton").hide();
        $("#IB_category").hide();
        $("#IB_searchOptionsTab").show();
        loadSearchOptions();
        
        break;
        
      case "view":
        alert('view');
        break;
    }
  }
};

// INIT STUFF

function initImageBank(_sectionFilter){
  // set sectionFilter
  sectionFilter = _sectionFilter;
  // Initialize adding tags
  $(function() { initialize_addTag_button("#IB_tagButtonWrap", '#IB_tagText', '') });
  
  // Setup search button/tab transitions
  var genre = getParameterByName("genre");
  if (genre != "") {
    setGenre(genre);
  }  
  var artist = getParameterByName("artist");
  if (artist != "") {
    setArtist(artist);
  }
  
  $("#IB_searchBox").unbind();
  $("#IB_searchBox").click(function() {
    loadSearch();
  });
    
  if (artist != "") {  
    loadArtist(0,artist);
  } else if (genre != "") {
    loadArtistList(0,genre);
  } else {
    loadBrowse();
    // Check for passed data
    checkForParams();
  }
  
  // TEMP
  $('.browseBars').click(function(){
      closeImagebank();
    });
    
  $('#IB_browser_frame').fadeIn()
}

$(document).ready(function() {
  
  initImageBank('Library')
  // Set up tag list sortability
  /*$( "#tag-list" ).sortable( {
    distance: 10,
    start: function(event, ui) { $("#sorting").val(1) }, // while sorting, change hidden value to 1
    stop: function(event, ui) { $("#sorting").val(0) }, // on ending, change the value back to 0
  } );*/ // this prevents the tag from being deleted when it's dragged
});
