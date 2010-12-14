/*
UvumiTools Crop V2.0.1 http://uvumi.com/tools/crop.html

Copyright (c) 2008 Uvumi LLC

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/
	
var uvumiCropper = new Class({
	
	Implements : [Events, Options],
	
	options : {
		maskOpacity:0.5,	//the overlay opacity. Because this property in not easy to directly implement with valid CSS in every browser, we set it with javacript. 0 is transparent, 1 is full opacity. If 0 or false, the mask is not generated at all and not updated (good for slow computers).
		maskClassName:'cropperMask',	//CSS class name to style the overlay. Only for backgound color, other properties are set with javascript.
		handleClassName:'cropperHandle',	//CSS class name to style handles. Then each handles reacives additional classes 'left', 'right', 'top' or 'bottom' for extra individual styling
		resizerClassName:'cropperResize',	//CSS class name to style the resizer: Mostly for border and cursor.
		wrapperClassName:'cropperWrapper',	//the image is injected a a wrapper. this is a CSS class to eventually add a border
		coordinatesClassName:'cropperCoordinates', // CSSS class of the coordinates box if enabled
		mini:{	//Minimum selection sizes in pixels. Those will also define the ratio if keepRatio is enabled
			x:80,
			y:60
		},
		handles:[	// drag handles to be added on the resizer's borders. Will create a handle for each array element. Can be a string ('top', 'left', 'bottom', 'rigth'), in which case the handle will be added in the middle of the corresponding segment, or a couple, in which case the handle will be added in the corresponding corner. You can create any combination from one to eight handles. If the array is empty or 'handles' = false, will be considered as not resizable.
			['top','left'],
			'top',
			['top','right'],
			'right',
			'left',
			['bottom','left'],
			'bottom',
			['bottom','right']
		],
		onComplete:$empty,	//function to execute everytime you finish moving/resizing the cropper. The function receive the top, left, height and width of the resizer. You can use this function to put those value in a form and later send them to a server script to process the image.
		onDestroy:$empty,	//fired when the destroy() function is called
		keepRatio:false, //if the aspect ratio, defined by the mini option, should be maintained when resizing. You can set to to false, but still manually maintain ration by holding shift while resizing. In this case it will use the current size as the ratio to keep. But you must tell you users about this feature.
		doubleClik:true, //if selection should maximize on double click
		handleSize:16, // the size in pixel of the resizing handles.
		coordinates:false,	//should display coordinates form or not
		preview:false, //if you pass an element ID or an element reference as preview, a live preview of the cropped image will be generated inside this element. If just 'true', it will be displayed in the coordinate box
		downloadButton:false,	//if true, add a download button to the toolbox, binded to the cropDownload function. If a string, it will be used as text for the button. if an object, it wll be used to generate extra parameter for the download query.
		cancelButton:false,	//if true, add a cancel button to the toolbox. Destroys the cropper. If a string, it will be used as text for the button.
		saveButton:false,	//if true, add a save button to the toolbox, binded to the cropSave function. If a string, it will be used as text for the button. if an object, it wll be used to generate extra parameter for the save query.
		adopt:false,	//can be a string, an element, or a collection to be injected in toolbox 
		parameters:{},	//extra parameter for download and save scripts
		coordinatesOpacity:0.25,	//if fasle, coordinate box opacity is 1 (if box needed), else, a float value between 0 and 1. Opacity fades in when hovered
		serverScriptSave:'/avatar-image/save', //path to server side script to save thumbnail. Must be relative to document because it's called via ajax, which does not allow cross domain request
		serverScriptDownload:'download-thumb.php', //path to server side script for direct file download (no copy saved on server). Can be relative or absolute. Can even be on a different domain if necessary.
		onRequestFail:function(){  //function to execute when ajax request fails (not the script itself, just reaching the server)  SAVE MODE ONLY
			alert("The request could not be performed.");
		},
		onCropFail:function(error){ //function to execute when the ajax cropping script returns an error. the error is passed as a string to the function. Default just alert the error to inform the user. SAVE MODE ONLY
			alert(error + 'image crop successful'); // temp hack - doktor J
			$$(this.previewWrapper,this.toolBox).destroy();
			this.wrapper.empty().setStyle('height','auto');
			image.inject(this.wrapper);
		},
		onCropSuccess:function(thumb){ //function to execute if the thumbnail has been saved successfully. This function receives the thumb file name only, not the full url, because javascript cannot guess what the url to acces the thumb directory on the server is, you'll have to provide it (here it's images/thumbs). This is just a sample function that replaces the image with the new generated thumbnail and display a success message, but you can have it do whatever you like : a redirection, open the new image in a popup, display it in a new element... SAVE MODE ONLY
			alert('Thumbnail was generated successfully.');
			new Asset.image('images/thumbs/'+thumb,{
				onload:function(image){ 
					$$(this.previewWrapper,this.toolBox).destroy();
					this.wrapper.empty().setStyle('height','auto');
					image.inject(this.wrapper);
				}.bind(this)
			});
			this.removeEvents();
			this.crop=$empty;
		},
		onDestroy:$empty //event function executed when the cropper is destroyed (can be usefull to remove some element you might have injected in the toolbox)
	},
	
	initialize : function(target,options){
		//we use a domready function here so we don't have to wrap the instance inside one
		window.addEvent('domready',function(){
			//target is the image we want to crop
			this.target = $(target);
			
			//just an idiot check before anything else, if target is not an image, just exits.
			if(!this.target.match('img')){
				return false;
			}
					
			this.setOptions(options);
			
			this.params = this.options.parameters;
			//Just creating a SHORTER variable name, because this one comes back often
			this.mini={};
			this.mini.x=this.options.mini.x.toInt();
			this.mini.y=this.options.mini.y.toInt();
			
			//some browser execute the Asset onload function twice (Opera), so we must use a flag to prevent from duplicate actions
			this.runonce = false;
			//we preload the image before doing anything, to make sure we get the right dimensions.
			new Asset.image(this.target.get('src'),{
				onload:function(image){
					if(this.runonce){
						return;
					}
					this.runonce=true;
					
					this.width = image.get('width');					
					
					//Generating the new elements. see the functions for more details
					this.buildCropper();
					
					//if maskOpacity is set to 0 or false, we don't even build it and just set the updateMask to empty,
					//so we don't have to test everytime or make a spacial version of the onDrag event
					if(this.options.maskOpacity){
						this.buildMask();
					}else{
						this.updateMask = $empty;
					}
					
					//initialize the dragging, using the target element as container,
					//On complete we fire the optional event function, providing the top, left, width and height of the selection a parameters.
					//Those coordinates are also stored in the object, so you can access them from an external function,
					//while going against object oriented programming rules which state that object variables are supposed to be private
					this.drag = new Drag.Move(this.resizer,{
						container:this.target,
						snap:0,
						onStart:this.hideHandles.bind(this),
						onComplete:function(){
							this.showHandles();
							this.fireEvent('onComplete',[this.top,this.left,this.width,this.height]);
						}.bind(this)
					});
					
					//We initializse the resizing objects if option resizable is set to true and there are resizing handles
					if(this.options.handles && this.options.handles.length){
						//we create two drag instance for vertical and horizontal for better control.
						//In some case one direction needs to be inverted, but not the other, which is not possible with only one instance
						//the drag are detached bedcause we start them manually
						this.resizeX = new Drag(this.resizer,{
							snap:0,
							modifiers:{
								x:'width',
								y:false
							},
							onComplete:this.stopResize.bind(this)
						}).detach();
						this.resizeY = new Drag(this.resizer,{
							snap:0,
							modifiers:{
								x:false,
								y:'height'
							},
							onComplete:this.stopResize.bind(this)
						}).detach();
						
						if(this.options.doubleClik){
							this.resizer.addEvent('dblclick',this.expandToMax.bind(this));
						}
						
						//add correct events depending on the ratio option
						if(this.options.keepRatio){
							this.ratioOn();
						}else{
							this.ratioOff();
						}
					}else{
						//if no resizing, we add much simple drag event
						this.drag.addEvent('drag',this.onDrag.bind(this));
					}
					//because preview is only refreshed when the selection is beeing moved/resized, we fire the drag event to generate the initial preview, before the user has done anything.
					this.drag.fireEvent('onDrag');
					this.drag.fireEvent('onComplete');
					//display the cropper
					this.show();
				}.bind(this)
			});
		}.bind(this));	
	},

/*
BUILDING FUNCTIONS
*/
	buildCropper : function(){
		//a wrapper element is created. it adopts the target element
		//using a wrapper is important because every positionning can be done relatively to it.
		//If you resize the window of the the document layout is modified, the mask and selection will stay aligned onto the picture.
		//It wouldn't be the case if we were just working directly in the documen body.
		//You may have to edit the wrapper's CSS to keep the original look of your page after it is injected around the image
		//(if image was floateed, had a margin ore a border, you'll have to set the same properties to the wrapper)
		//That's why we assign it a css class.
		this.wrapper = new Element('div',{
			'class':this.options.wrapperClassName,
			styles:{
				position:'relative',
				width : this.target.getSize().x,
				height :this.target.getSize().y,
				overflow:'hidden'
			}
		}).wraps(this.target);
		this.border = this.target.getStyle('border-left');
		//just in case, to avoid bad results because of browser default styling
		this.target.setStyles({
			margin:0,
			border:0,
			'float':'none'
		});
		
		//get the target element coordinates, will be used a lot. We suppose the element position doesn't change
		this.target_coord=this.target.getCoordinates(this.wrapper);
		
		this.scaleRatio = this.width/this.target_coord.width;	
		
		//We might modify the original mimimum values in the next tests,
		//but wew are still going to need them for the preview, so we make copies
		this.previewSize = {
			x:this.mini.x,
			y:this.mini.y
		};
		
		//This is just for extrem cases, if you have an image smaller than the minimum required, or a resized image with weird proportions (super tall or super wide)
		if(this.target_coord.width<this.mini.x){
			this.mini.y = this.target_coord.width*this.mini.y/this.mini.x;
			this.mini.x = this.target_coord.width;
		}
		if(this.target_coord.height<this.mini.y){
			this.mini.x = this.target_coord.height*this.mini.x/this.mini.y;
			this.mini.y = this.target_coord.height;
		}
		
		//the main selection element,  which will be draggable and resizable, generated from the options. It is centered on the target image
		//We assign it a CSS class, because it's important to give it a border, especially if you disable the mask.
		//Also, use  CSS to set a blank GIF background image, otherwise the mousedown event is not fired in IE if the element doesn't have a "solid" background
		//The critical preoperties, like position and dimension are hardcoded by safety.
		this.resizer = new Element('div',{
			'class':this.options.resizerClassName,
			title:'Hold mouse down to move',
			styles:{
				position:'absolute',
				display:'block',
				margin:0,
				opacity:0,
				width:(this.scaleRatio<1?(this.mini.x/this.scaleRatio).toInt():this.mini.x),
				height:(this.scaleRatio<1?(this.mini.y/this.scaleRatio).toInt():this.mini.y),
				left:(this.target_coord.left+(this.target_coord.width/2)-(this.mini.x/2)).toInt(),
				top:(this.target_coord.top+(this.target_coord.height/2)-(this.mini.y/2)).toInt(),
				zIndex:5
			}
		}).inject(this.target,'after');
		
		//In our case, it is important that the selection has exactly the dimension we want it to have, because we want to use its coordinates
		//So, because the selection element has a margin and a padding(requiered), we must substract thos values everytime we set the selection width or height
		//we set it once in the object, so we doesn't have to calculate it everytime
		this.margin=2*this.resizer.getStyle('border-width').toInt();
		
		this.resizer.setStyles({
			width:(this.scaleRatio<1?(this.mini.x/this.scaleRatio).toInt():this.mini.x) - this.margin,
			height:(this.scaleRatio<1?(this.mini.y/this.scaleRatio).toInt():this.mini.y) - this.margin
		});
		
		
		if(this.options.coordinates || (this.options.preview && !$(this.options.preview)) || this.options.saveButton || this.options.downloadButton || this.options.cancelButton || this.options.adopt){
			this.buildToolBox();
		}else{
			this.updateCoordinates = $empty;
		}
		
		if(this.options.coordinates){
			this.buildCoordinates();
		}
		
		//if a string or element has been set for preview option, and if the element exists,
		//we generate the preview picture
		if(this.options.preview){
			if($(this.options.preview)){
				this.preview = $(this.options.preview);
				//we put the preview in a wrapper div with a fixed height, because preview height and width may change.
				this.previewWrapper = new Element('div',{
					styles:{
						height:this.previewSize.y+2*this.preview.getStyle('border-width').toInt()+this.preview.getStyle('margin-top').toInt()+this.preview.getStyle('margin-bottom').toInt()
					}
				}).wraps(this.preview);
			}else{
				var previewWrapper = new Element('div',{
					'class':'preview'
				}).inject(this.toolBox,'top');
				this.preview = new Element('div').inject(previewWrapper)
			}
			
			//Setting the preview container
			this.preview.setStyles({
				display:'block',
				position:'relative',
				width:this.previewSize.x,
				height:this.previewSize.y,
				overflow:'hidden',
				margin:'auto',
				fontSize:0,
				lineHeight:0,
				opacity:0
			});
			
			//cloning the original image for the preview
			this.previewImage = this.target.clone();
			this.previewImage.removeProperties('width','height').setStyle('position','absolute').inject(this.preview);			
			this.addEvent('onPreview',this.updatePreview.bind(this));
		}
		
		if(this.options.adopt){
			var div = new Element('div',{
				styles:{
					clear:'both'
				}
			}).inject(this.toolBox);
			switch($type(this.options.adopt)){
				case 'string':
					div.set('html',this.options.adopt);
					break;
				case 'element':
				case 'collection':
					div.adopt(this.options.adopt);
					break;
			}
		}
		
		if(this.options.downloadButton || this.options.saveButton || this.options.cancelButton){
			var p = new Element('p').inject(this.toolBox);
			if(this.options.downloadButton){
				var saveButton = new Element('button',{
					type:'button',
					html:($type(this.options.downloadButton)=='string'?this.options.downloadButton:'Download'),
					events:{
						click:this.cropDownload.bind(this,($type(this.options.downloadButton)=='objecy'?this.options.downloadButton:false))
					}
				}).inject(p);
			}
			
			if(this.options.saveButton){
				var saveButton = new Element('button',{
					type:'button',
					html:($type(this.options.saveButton)=='string'?this.options.saveButton:'Save'),
					events:{
						click:this.cropSave.bind(this,($type(this.options.saveButton)=='object'?this.options.saveButton:false))
					}
				}).inject(p);
			}
			
			if(this.options.cancelButton){
				var saveButton = new Element('button',{
					type:'button',
					html:($type(this.options.cancelButton)=='string'?this.options.cancelButton:'cancel'),
					events:{
						click:this.destroy.bind(this)
					}
				}).inject(p);
			}
		}
		
		//create resizing handles
		if(this.options.handles && this.options.handles.length){
			this.options.handles.each(this.buildHandle,this);
		}
		this.rezr_coord=this.resizer.getCoordinates(this.wrapper);
	},
	
	//generic function to build one handle
	buildHandle:function(coord){
		coord=$splat(coord);
		var x = '';
		var y = '';
		['left','right'].each(function(abs){
			if(coord.contains(abs)){
				x=abs;
			}
		});
		['top','bottom'].each(function(ord){
			if(coord.contains(ord)){
				y=ord;
			}
		});
		//creates the handle element
		var handle = new Element('div',{
			'class':this.options.handleClassName+' '+y+' '+x,
			title:(this.options.keepRatio?'Drag to resize':'Hold Shift to maintain aspect ratio'),
			tween:{
				duration:250,
				link:'cancel'
			},
			styles:{
				position:'absolute',
				height:this.options.handleSize,
				width:this.options.handleSize,
				fontSize:0
			},
			events:{
				mousedown:this.startResize.bind(this)
			}
		});
		handle.inject(this.resizer);
		//position it depending on the passed arguments
		if(y == 'top'){
			handle.setStyle('top',-((this.options.handleSize+this.margin)/2).toInt());
		}else if(y == 'bottom'){
			handle.setStyle('bottom',-((this.options.handleSize+this.margin)/2).toInt());
		}else{
			handle.setStyles({
				top:'50%',
				marginTop:-(this.options.handleSize/2).toInt()
			});
		}
		if(x == 'left'){
			handle.setStyle('left',-((this.options.handleSize+this.margin)/2).toInt());
		}else if(x == 'right'){
			handle.setStyle('right',-((this.options.handleSize+this.margin)/2).toInt());
		}else{
			handle.setStyles({
				left:'50%',
				marginLeft:-(this.options.handleSize/2).toInt()
			});
		}
	},
	
	//build the overlay mask
	buildMask : function(){
		this.innermask=this.target.clone();
		this.innermask.setProperties(this.target.getProperties('width','height'));
		this.innermask.setStyles({
			position:'absolute',
			padding:0,
			margin:0,
			top:0,
			left:0,
			zIndex:4,
			opacity:0
		}).inject(this.wrapper);
		this.outtermask = new Element('div',{
			'class':this.options.maskClassName,
			styles:{
				position:'absolute',
				padding:0,
				margin:0,
				top:0,
				left:0,
				width:'100%',
				height:this.target_coord.height,
				zIndex:3,
				opacity:0
			},
			events:{
				'click':this.moveToClick.bind(this)
			}
		}).inject(this.wrapper);
		this.slide = new Fx.Elements($$(this.resizer,this.innermask,this.previewImage,this.toolBox),{
			onComplete:function(){
				this.drag.fireEvent('onDrag');
				this.drag.fireEvent('onComplete');
			}.bind(this)
		});
	},
	
	buildToolBox:function(){
		this.toolBox = new Element('div',{
			'class':this.options.coordinatesClassName + (Browser.Engine.trident?' IE':''),
			styles:{
				position:'absolute',
				zIndex:5,
				opacity:0
			}
		}).inject($(document.body));
		this.toolBoxOffesetLeft=0;
		this.toolBoxOffesetTop=10;
		if(this.options.coordinatesOpacity && this.options.coordinatesOpacity < 1){
			this.toolBox.set('tween',{duration:'short',link:'cancel'}).addEvents({
				mouseenter:function(){
					this.fade('in');
				},
				mouseleave:function(){
					this.toolBox.fade(this.options.coordinatesOpacity);
				}.bind(this)
			});
		}
		this.toolBoxTopBar = new Element('div',{
			'class':'topbar',
			html:'=drag here=',
			styles:{
				position:'absolute',
				top:0,
				left:0,
				width:'100%'
			}
		}).inject(this.toolBox,'top');
		new Drag(this.toolBox,{
			handle:this.toolBoxTopBar,
			onComplete:function(){
				var coord1 = this.resizer.getCoordinates();
				var coord2 = this.toolBox.getCoordinates();
				this.toolBoxOffesetLeft = coord2.left - coord1.left;
				this.toolBoxOffesetTop = coord2.top - coord1.bottom;
			}.bind(this)
		});
	},
	
	//create coordinates box
	buildCoordinates:function(){
		this.topcoord = new Element('input',{type:'text'});
		this.leftcoord = new Element('input',{type:'text'});
		this.heightcoord = new Element('input',{type:'text'});
		this.widthcoord = new Element('input',{type:'text'});
		$$(this.topcoord,this.leftcoord,this.heightcoord,this.widthcoord).addEvent('change',this.updateFromInput.bind(this));
		var labelX = new Element('label',{
			html:'x : '
		});
		var labelY = new Element('label',{
			html:'y : '
		});
		var labelW = new Element('label',{
			html:'w : '
		});
		var labelH = new Element('label',{
			html:'h : '
		});
		this.toolBox.adopt(labelX,this.leftcoord,labelY,this.topcoord,new Element('br'),labelW,this.widthcoord,labelH,this.heightcoord,new Element('br'));
	},	
/*
EVENT FUNCTIONS
*/

	//this function is assigned to each handle mousedown event. It's a big hack that would be to long to explain, but it works. If you don't want to break it,  don't try to fix it.
	startResize:function(e){
		this.resizing = true;
		var handle = $(e.target);
		if(e.shift && !this.options.keepRatio){
			this.ratioOn();
		}
		this.drag.addEvent('beforeStart',function(){
			this.drag.options.limit={
				x:[0,(this.rezr_coord.right-(this.mini.x/this.scaleRatio).toInt())],
				y:[0,(this.rezr_coord.bottom-(this.mini.y/this.scaleRatio).toInt())]
			};
		}.bind(this));
		if(handle.hasClass('left')){
			this.resizeX.options.invert=true;
			this.drag.options.modifiers.x='left';
			this.resizeX.options.limit={x:[
				((this.mini.x/this.scaleRatio).toInt()-this.margin),
				(this.rezr_coord.right-this.margin)
			]};
			this.resizeX.start(e);
		}else if(handle.hasClass('right') || this.ratio){
			this.resizeX.options.invert=false;
			this.drag.options.modifiers.x=false;
			this.resizeX.options.limit={x:[
				((this.mini.x/this.scaleRatio).toInt()-this.margin),
				((this.target_coord.width-this.margin)-this.rezr_coord.left)
			]};
			this.resizeX.start(e);
		}else{
			this.drag.options.modifiers.x=false;
		}
		if(handle.hasClass('top')){
			this.resizeY.options.invert=true;
			this.drag.options.modifiers.y='top';
			this.resizeY.options.limit={y:[
				((this.mini.y/this.scaleRatio).toInt()-this.margin),
				(this.rezr_coord.bottom-this.margin)
			]};
			this.resizeY.start(e);
		}else if(handle.hasClass('bottom') || this.ratio){
			this.resizeY.options.invert=false;
			this.drag.options.modifiers.y=false;
			this.resizeY.options.limit={y:[
				((this.mini.y/this.scaleRatio).toInt()-this.margin),
				((this.target_coord.height-this.margin)-this.rezr_coord.top)
			]};
			this.resizeY.start(e);
		}else{
			this.drag.options.modifiers.y=false;
		}		
	},
	
	//fired when mouseup on handles
	stopResize:function(){
		this.resizing = false;
		this.drag.options.modifiers={x:'left',y:'top'};
		this.drag.options.limit=false;
		this.drag.removeEvents('beforeStart');
		if(this.ratio){
			this.check();
			this.onDrag();
			if(!this.options.keepRatio){
				this.ratioOff();
			}
		}
	},
	
	hideHandles:function(){
		if(!this.resizing){
			$$('.'+this.options.handleClassName).fade('out');
		}
	},
	
	showHandles:function(){
		if(!this.resizing){
			$$('.'+this.options.handleClassName).fade('in');
		}
	},
	
	//fired when moving/resizing the cropper, it updates the mask and the top, left and width value. It also updates the preview
	onDrag:function(){
		this.updateMask();
		this.top = ((this.rezr_coord.top-this.target_coord.top)*this.scaleRatio).toInt();
		this.left = ((this.rezr_coord.left-this.target_coord.left)*this.scaleRatio).toInt();
		this.width = Math.max((this.rezr_coord.width*this.scaleRatio).toInt(),this.mini.x);
		this.height = Math.max((this.rezr_coord.height*this.scaleRatio).toInt(),this.mini.y);
		this.updateCoordinates();
		this.fireEvent('onPreview',[this.top,this.left,this.width,this.height]);
	},
	
	//fired when moving/resizing the cropper with keepRatio enabled
	onDragRatio:function(){
		if(this.resizing){
			this.check();
		}
		this.onDrag();
	},
	
	check:function(){
		this.rezr_coord=this.resizer.getCoordinates(this.wrapper);
		if(this.ratio>1){
			var width = (this.rezr_coord.height*this.ratio).toInt();
			var height = this.rezr_coord.height;
			this.resizer.setStyle('width',Math.min(width,this.target_coord.width-this.rezr_coord.left)-this.margin);
		}else{
			var width = this.rezr_coord.width;
			var height = (this.rezr_coord.width/this.ratio).toInt();
			this.resizer.setStyle('height',Math.min(height,this.target_coord.height-this.rezr_coord.top)-this.margin);
		}
		if(this.drag.options.modifiers.x){
			this.resizer.setStyle('left',Math.max(this.rezr_coord.right-width,0));
		}
		if(this.drag.options.modifiers.y){
			this.resizer.setStyle('top',Math.max(this.rezr_coord.bottom-height,0));
		}
		this.rezr_coord=this.resizer.getCoordinates(this.wrapper);
		if(this.rezr_coord.right>=this.target_coord.width){
			this.resizer.setStyle('height',(this.rezr_coord.width/this.ratio).toInt()-this.margin);
		}
		if(this.rezr_coord.bottom>=this.target_coord.height){
			this.resizer.setStyle('width',(this.rezr_coord.height*this.ratio).toInt()-this.margin);
		}
	},
	
	//Function to update the preview
	updatePreview: function(top,left,width,height){	
		if(height*this.previewSize.x/width<this.previewSize.y){
			this.preview.setStyles({
				width:this.previewSize.x,
				height:(this.previewSize.x*height/width).toInt()		
			});
			this.previewImage.setStyles({
				width:(this.target_coord.width*this.previewSize.x*this.scaleRatio/width).toInt(),
				height:'auto',
				top:-(top*this.previewSize.x/width).toInt(),
				left:-(left*this.previewSize.x/width).toInt()
			});
		}else{
			this.preview.setStyles({
				height:this.previewSize.y,
				width:(this.previewSize.y*width/height).toInt()
			});
			this.previewImage.setStyles({
				height:(this.target_coord.height*this.previewSize.y*this.scaleRatio/height).toInt(),
				width:'auto',
				top:-(top*this.previewSize.y/height).toInt(),
				left:-(left*this.previewSize.y/height).toInt()
			});
		}
	},
	
	//update the mask position
	updateMask : function(){	
		this.rezr_coord = this.resizer.getCoordinates(this.wrapper);
		this.innermask.setStyle('clip','rect('+this.rezr_coord.top+'px '+this.rezr_coord.right+'px '+this.rezr_coord.bottom+'px '+this.rezr_coord.left+'px)');
	},
	
	//update coordinates box and position
	updateCoordinates:function(){
		if(this.options.coordinates){
			this.leftcoord.set('value',this.left);
			this.topcoord.set('value',this.top);
			this.widthcoord.set('value',this.width);
			this.heightcoord.set('value',this.height);
		}
		var coords = this.resizer.getCoordinates();
		this.toolBox.setStyles({
			top:coords.bottom + this.toolBoxOffesetTop,
			left:coords.left + this.toolBoxOffesetLeft
		});
	},
	
	//allow to type dimensions in the coordinate box if enabled
	updateFromInput:function(e){
		var top = (this.topcoord.get('value').clean()/this.scaleRatio || 0).toInt();
		var left = (this.leftcoord.get('value').clean()/this.scaleRatio || 0).toInt();
		var height = (this.heightcoord.get('value').clean()/this.scaleRatio ||0).toInt();
		var width = (this.widthcoord.get('value').clean()/this.scaleRatio || 0).toInt();
		
		top = top.limit(0,this.target_coord.height - this.rezr_coord.height);
		left = left.limit(0,this.target_coord.width - this.rezr_coord.width);
		height = height.limit((this.mini.y/this.scaleRatio).toInt(),this.target_coord.height - this.rezr_coord.top);
		width = width.limit((this.mini.x/this.scaleRatio).toInt(),this.target_coord.width - this.rezr_coord.left);
		if(this.ratio){
			if($(e.target) == this.widthcoord){
				height = Math.min((width/this.ratio).toInt(),this.target_coord.height - this.rezr_coord.top);
				width = (height*this.ratio).toInt();
			}else if($(e.target) == this.heightcoord){
				width =  Math.min((height*this.ratio).toInt(),this.target_coord.width - this.rezr_coord.left);
				height = (width/this.ratio).toInt();
			}
		}
		this.resizer.setStyles({
			'height':height-this.margin,
			'width':width-this.margin,
			'top':top,
			'left':left
		});
		this.drag.fireEvent('drag');
		this.drag.fireEvent('onComplete');
	},
	
	//function applied to the mask onclick event, to move to cropper to the click coordinates. Updates the preview at the same time
	moveToClick : function(e){
		var mouseX = e.page.x;
		var mouseY = e.page.y;
		var wrap_coord = this.wrapper.getPosition();
		var localX = mouseX-wrap_coord.x;
		var localY = mouseY-wrap_coord.y;
		var top = (localY-(this.rezr_coord.height/2).toInt()).limit(0,this.target_coord.height-this.rezr_coord.height);
		var left = (localX-(this.rezr_coord.width/2).toInt()).limit(0,this.target_coord.width-this.rezr_coord.width);
		var right = left+this.rezr_coord.width;
		var bottom = top+this.rezr_coord.height;
		var effect = {
			0:{
				top:top,
				left:left
			},
			1:{
				clip:[[this.rezr_coord.top,this.rezr_coord.right,this.rezr_coord.bottom,this.rezr_coord.left],[top,right,bottom,left]]
			}
		};
		if(this.preview){
			var prevSize = this.preview.getSize();
			effect[2]={
				top:-(top*prevSize.y/(bottom-top)).toInt(),
				left:-(left*prevSize.x/(right-left)).toInt()
			};
		}
		if(this.toolBox){
			effect[this.slide.elements.length-1]={
				'top':bottom+wrap_coord.y + this.toolBoxOffesetTop,
				'left':left+wrap_coord.x + this.toolBoxOffesetLeft
			};
		}
		this.slide.start(effect);
	},
	
	expandToMax:function(){
		if(this.ratio){
			if(this.target_coord.width/this.target_coord.height<this.ratio){
				var top = ((this.target_coord.height-(this.target_coord.width/this.ratio))/2).toInt();
				var left = 0;
				var width = this.target_coord.width-this.margin;
				var height = (this.target_coord.width/this.ratio).toInt()-this.margin;
			}else{
				var top = 0;
				var left = ((this.target_coord.width-(this.target_coord.height*this.ratio))/2).toInt();
				var width = (this.target_coord.height*this.ratio).toInt()-this.margin;
				var height = this.target_coord.height-this.margin;
			}
		}else{
			var top = 0;
			var left = 0;
			var width = this.target_coord.width-this.margin;
			var height = this.target_coord.height-this.margin;
			if(this.preview){
				if(height*this.previewSize.x/width<this.previewSize.y){
					this.preview.setStyles({
						width:this.previewSize.x,
						height:(this.previewSize.x*height/width).toInt()
					});
				}else{
					this.preview.setStyles({
						height:this.previewSize.y,
						width:(this.previewSize.y*width/height).toInt()
					});
				}
			}
		}
		var effect = {
			0:{
				top:top,
				left:left,
				width:width,
				height:height
			},
			1:{
				clip:[[this.rezr_coord.top,this.rezr_coord.right,this.rezr_coord.bottom,this.rezr_coord.left],[top,left+width,height+top,left]]
			}
		};
		if(this.preview){
			var coord = this.previewImage.getCoordinates(this.preview);
			coord.bottom = null;
			coord.right = null;
			this.previewImage.setStyles(coord);
			var prevSize = this.preview.getSize();
			effect[2]={
				top:-(top*this.previewSize.y/height).toInt(),
				left:-(left*this.previewSize.x/width).toInt(),
				width:(this.target_coord.width*prevSize.x*this.scaleRatio/width).toInt(),
				height:(this.target_coord.height*prevSize.y*this.scaleRatio/height).toInt()
			};
		}
		if(this.toolBox){
			var wrap_coord = this.wrapper.getPosition();
			effect[this.slide.elements.length-1]={
				'top':height + wrap_coord.y + this.toolBoxOffesetTop,
				'left':left + wrap_coord.x + this.toolBoxOffesetLeft
			};
		}
		this.slide.start(effect);
	},
	
	//hide the cropper + preview + mask
	hide:function(){
		$$(this.resizer,this.innermask,this.outtermask,this.preview,this.toolBox).fade('out');
	},
	
	//unhide the cropper
	show:function(){
		$$(this.resizer,this.innermask,this.preview).fade('in');
		if(this.options.maskOpacity){
			this.outtermask.fade(this.options.maskOpacity);
		}
		if(this.toolBox){
			this.toolBox.fade(this.options.coordinatesOpacity||'in');
		}
	},
	
	//show/hide the mask
	toggle:function(){
		if(this.resizer.getStyle('opacity')==1){
			this.hide();
		}else{
			this.show();
		}
	},
	
	//remove the generated elements
	destroy:function(){
		//if you need to remove the cropper when you're done
		this.hide();
		this.target.setStyle('border',this.border);
		(function(){
			this.target.replaces(this.wrapper);
			if(this.previewWrapper){
				this.preview.empty().setStyles({
					height:0,
					width:0
				}).replaces(this.previewWrapper);
			}
			this.fireEvent('onDestroy',this.target);
			if(this.toolBox){
				this.toolBox.destroy();
			}
		}).delay(600,this);
	},
	
	//enable the ratio maintaining. Either called if keepRatio option true, or if shift is pressed when starting to resize
	ratioOn:function(){
		this.ratio = this.rezr_coord.width/this.rezr_coord.height;
		this.drag.removeEvents('drag');
		this.drag.addEvent('drag',this.onDragRatio.bind(this));
	},
	
	//disable ratio. Call on initialisation if keepRatio is false, or after a manually maintainted ratio resizing 
	ratioOff:function(){
		this.ratio = false;
		this.drag.removeEvents('drag');
		this.drag.addEvent('drag',this.onDrag.bind(this));
	},
	
	//function done on reauest to update the image src and update the cropper at the same time. Not heavily tested. Seems to work, but not sure it's bug free
	changeImage:function(src){
		new Asset.image(src,{
			onload:function(img){
				this.hide();
				this.target.get('tween').start('opacity',0).chain(
					function(){	
						this.scaleRatio = img.get('width')/this.target_coord.width;
						var height = (img.get('height')/this.scaleRatio).toInt();
						this.wrapper.setStyle('height',height);
						this.target.set({
							width:this.target_coord.width,
							height:height
						});
						this.target_coord=this.target.getCoordinates(this.wrapper);
						
						this.target.set('src',src);
						
						if(this.target_coord.width<this.mini.x){
							this.mini.y = this.target_coord.width*this.mini.y/this.mini.x;
							this.mini.x = this.target_coord.width;
						}
						if(this.target_coord.height<this.mini.y){
							this.mini.x = this.target_coord.height*this.mini.x/this.mini.y;
							this.mini.y = this.target_coord.height;
						}
						
						this.resizer.setStyles({
							width:(this.mini.x/this.scaleRatio).toInt() - this.margin,
							height:(this.mini.y/this.scaleRatio).toInt() - this.margin,
							left:(this.target_coord.left+(this.target_coord.width/2)-(this.mini.x/2)).toInt(),
							top:(this.target_coord.top+(this.target_coord.height/2)-(this.mini.y/2)).toInt()
						});
						this.innermask.setProperties(this.target.getProperties('width','height','src'));
						this.outtermask.setStyle('height',this.target_coord.height);
						
						if(this.previewImage){
							this.previewImage.set('src',src);
						}
						
						this.drag.fireEvent('onDrag');
						this.drag.fireEvent('onComplete');
						this.show();
						this.target.get('tween').start('opacity',1);
					}.bind(this));
			}.bind(this)
		});
	},
	
	//function to call the download script. If an object is passed as argument, it will be added to the default parameters list
	cropDownload:function(param){
		this.prepareParameters(param);
		params = new Hash(this.params);
		location.href=this.options.serverScriptDownload+"?"+params.toQueryString();
	},
	
	//function to call the save script. If an object is passed as argument, it will be added to the default parameters list
	cropSave:function(param){
		this.prepareParameters(param);
		this.request = new Request.JSON({
			url:this.options.serverScriptSave,
			data:this.params,
			onSuccess:function(json,response){
				if(json){
					if(json.error){
						this.fireEvent('onCropFail',json.error);
					}else if(json.success){
						this.fireEvent('onCropSuccess',json.success);
					}
				}else{
					this.fireEvent('onCropFail',response);
				}
				
			}.bind(this),
			onFailure:function(){
				this.fireEvent('onRequestFail');
			}.bind(this)
		}).send();
	},
	
	prepareParameters:function(param){
		var params = {
			filename:this.target.get('src').split('/').getLast(),
			max_height:this.mini.y,
			max_width:this.mini.x,
			top:this.top,
			left:this.left,
			width:this.width,
			height:this.height
		};
		this.addParameters(params);
		this.addParameters(param);
	},
	
	addParameters:function(params){
		if($type(params)=='object'){
			this.params = $merge(this.params,params);
		}
	}
});
