
#Ver 1.0 (no dbblob) 

class Imagex
 
  attr_accessor :imagename, :imageid,:imageaspect, :imageheight, :imagewidth, :imagetype, :imagesize,
:imageurl, :imagefilepath, :patho, :pathr, :imagepathsrc, :imagepathresize, :baseimageurl 

  def initialize (tmpdirname="E:/hellodata/rubyapps/test1/public",baseimageurl ="http://localhost:3000")
    #tmpdirname = the path to where image files will be - they will be copied into /img_src/ and /img/ 

    @baseimageurl = baseimageurl
    
    @patho = "/img_src/"
    @pathr = "/img/";
      
    @imagepathsrc = tmpdirname + @patho
    @imagepathresize = tmpdirname + @pathr
    
    @imagename = "" 
    @imageid = 0
      
    @imageaspect = 1  
      
    @imageheight = 0  
    @imagewidth = 0 
    @imagetype = "" 
    @imagesize = ""
      
    @imageurl = ""

    @imagefilepath = ""
  end 
  
  def  imagexadd(imagepath = "." ,resize=0,blankimage ="")
    size = File.size?(imagepath)
    tmpnewfilename = ""
  
    if (size)
      tmpfilename = File.basename(imagepath)
      tmpsqlimagename = tmpfilename.gsub(/[^A-Za-z0-9.]+/,"") #/ extra slash for the editor
      tmpnewfilename = tmpsqlimagename
      
      #height width and type 
      #format from image magick: +height+width+sizeB+TYPE++++---
      tmpidentify = `#{"identify -format +%H+%W+%b+%[magick]++++++++--- " + imagepath} `
      
      if (tmpidentify.rindex("---"))
        tmparray = tmpidentify.split("+") 
        
        tmpheight   = tmparray[1].to_f
        tmpwidth   = tmparray[2].to_f
        tmpsize   = tmparray[3].to_i
        tmptype   = tmparray[4].downcase
        tmptype   = tmptype.sub('jpeg','jpg')
        tmptype    = tmptype[0,3]
        
        if (tmpheight > 0  && tmpwidth > 0)

          if (tmpsqlimagename.length > 55)
            tmpsqlimagename = tmpsqlimagename[0,55]
          end 
          
          # get the image ID from the database
          sql = ActiveRecord::Base.connection()
          newid = sql.insert("insert into images (image_name,height,width,type,size,Original ) values ('#{tmpsqlimagename}',#{tmpheight},#{tmpwidth},'#{tmptype}',#{tmpsize},'P') ")

          if (newid > 0)
            #####
            #### create a filename of the appropriate length preceded by 'a'  ### 
            if (tmpnewfilename.length > 10)
              tmpnewfilename = tmpnewfilename[-10,10]
            elsif  (tmpnewfilename.length  <8) 
              tmpnewfilename =  (rand(24)+65).chr + (rand(24)+65).chr + tmpnewfilename
            end
            
            tmpnewfilename =  "a" +  (rand(24)+66).chr +  (rand(24)+66).chr + tmpnewfilename  
            tmpnewfilename = tmpnewfilename.downcase
            
            #####
            # encode the image id in the file name with:  ("2","1","5","9","0","6")("z","i","s","q","O","b");
            tmpsid = newid.to_s
            # array replacement would be better but didn tfind the syntax in time 
            tmpsid.gsub!("2","z");tmpsid.gsub!("1","i");tmpsid.gsub!("5","s");tmpsid.gsub!("9","q");tmpsid.gsub!("0","o");tmpsid.gsub!("6","b")
            
            tmpnewfilename = tmpsid + tmpnewfilename
            tmpnewpath= @imagepathsrc + tmpnewfilename
            tmpren = File.rename(imagepath, tmpnewpath)
            
            if (tmpren == 0)
              if (tmpnewpath.length < 100 )
                if (tmpsize < 15128640)
                  #write BLOB, file path 
                  #! this version is not writing the BLOB
                  tmpupdate = sql.update("update images set  original_path = '#{tmpnewpath}', original ='Y' where id = #{newid} ") 
                else
                  #write filepath only 
                  tmpupdate = sql.update("update images set  original_path = '#{tmpnewpath}', original ='Y' where id = #{newid} ") 
                end
              else
                if (tmpsize < 15128640)
                  #write BLOB, nofile path - change status to B
                  #remove below (=0)  when statement is added in 
                  tmpupdate = 0
                else
                  #considered to be a failed add- return a null object
                  tmpupdate = 0 
                end
              end
              if (tmpupdate > 0)
                #successful add
                
                @imagename = tmpnewfilename;
                   
                @imageheight   = tmpheight  
                @imagewidth    = tmpwidth 
                @imagetype    = tmptype  
                @imagesize    = tmpsize 
                @imagefilepath   = tmpnewpath 
                
                @imageid = newid
                
                if (tmpheight > 0 && tmpwidth > 0)
                  @imageaspect = (tmpheight / tmpwidth).round(2); 
                end
              
                if (resize.to_i > 0 && resize.to_i < tmpwidth)
                  # resizeimagenew ($Resize,$tmpcontent,$tmpwidth,$tmpheight,$tmpimageID)
                  resiz  = resizeimagenew(resize,tmpnewpath,@imagepathresize,newid,tmpnewfilename )
                  #note: @imageurl set in above function & other parameters will be overriden
                  # after the image resizes
                else
                  #returned URL for imagepath @imageurl
                  @imageurl =  @baseimageurl + @patho  +tmpnewfilename
                end
              else
                #unsuccessful
                @imagename =  File.basename(blankimage)
                @imageid = 0 
                @imagefilepath = ""
                @imageurl = blankimage
              end
            else
              @imageurl = blankimage
            end
          else
            @imageurl = blankimage
          end 
        else
          #set flag for unsuccessful
          @imageurl = blankimage
        end
      else
        @imageurl = blankimage
        ##puts('didnotreadimage invalid')
      end
    else
      @imageurl = blankimage
    end
  end
  
  def resizeimagenew(resize,tmpnewpath,tmpresizepath,tmpnewid,tmpnewfilename2)
    #if it's made it to this function, the paramaters have been validated !
    #resize the image - resized before getting an ID, for slight lag time. 
    
    #below will cause the new file to be jpg - in the case the extension is missing probbaly not going to work.
    tmpnewfilename2.sub!('.png','.jpg');tmpnewfilename2.sub!('.tif','.jpg');tmpnewfilename2.sub!('.gif','.jpg');tmpnewfilename2.sub!('.bmp','.jpg');tmpnewfilename2.sub!('.tiff','.jpg');tmpnewfilename2.sub!('.gif','.jpg');
    
    tmpresizedname = tmpresizepath +"t" + tmpnewfilename2 
    tmpresize = `#{"convert  -verbose -strip " +tmpnewpath+ " -resize " + resize.to_s +  " " + tmpresizedname} `
    
    #get a database ID
    sql = ActiveRecord::Base.connection()
    newid2 = sql.insert("insert into images (image_name,width,type,Original ) values ('#{tmpnewfilename2}',#{resize},'jpg','P') ") 
    #retwrns id 
    # get info about the resized file #
    
    tmpidentify = `#{"identify -format +%H+%W+%b+%[magick]++++++++--- " + tmpresizedname} `
      
    if (tmpidentify.rindex("---"))
      
      tmparray = tmpidentify.split("+") 
        
      tmpheight   = tmparray[1].to_f
      tmpwidth   = tmparray[2].to_f
      tmpsize   = tmparray[3].to_i
      tmptype   = tmparray[4].downcase
      tmptype   = tmptype.sub('jpeg','jpg')
      tmptype    = tmptype[0,3]
      # end of getting info on the resized file
      if (newid2 > 0)
      
        #####
        #### create a filename of the appropriate length preceded by 'a'  ### 
        tmpnewfilename =  "a" +  resize.to_s + (rand(24)+66).chr +  (rand(24)+66).chr +  (rand(24)+66).chr + (rand(24)+66).chr
        tmpnewfilename = tmpnewfilename.downcase + "." +tmptype
        #####
        # encode the image id in the file name with:  ("2","1","5","9","0","6")("z","i","s","q","O","b");
        tmpsid = newid2.to_s
        # array replacement would be better but didn tfind the syntax in time 
        tmpsid.gsub!("2","z");tmpsid.gsub!("1","i");tmpsid.gsub!("5","s");tmpsid.gsub!("9","q");tmpsid.gsub!("0","o");tmpsid.gsub!("6","b")
        tmpnewfilename = tmpsid + tmpnewfilename
        tmpnewpath= @imagepathresize + tmpnewfilename
        
        tmpren = File.rename(tmpresizedname, tmpnewpath)
              
          if (tmpren == 0)
            #write BLOB, file path 
            #! this version is not writing the BLOB
            #tmpupdate = 0 
            tmpinsert = sql.insert("insert into alt_images (id,alt_image_id,height,width,size,type,watermark_id,conversion_id) values ( #{tmpnewid},#{newid2},#{tmpheight},#{tmpwidth},#{tmpsize},'jpg',0,0) ")
            tmpupdate = sql.update("update images set  original_path = '#{tmpnewpath}', original ='N',type='#{tmptype}',width=#{tmpwidth},height=#{tmpheight} , size  =#{tmpsize} where id = #{newid2} ") 
            if (tmpupdate > 0 && tmpinsert == 0)
              #successful add
              
              @imagename = tmpnewfilename;

              @imageheight   = tmpheight  
              @imagewidth    = tmpwidth 
              @imagetype    = tmptype  
              @imagesize    = tmpsize 
              @imagefilepath   = tmpnewpath 
              # set in calling function @ imageid     = newid2
              # this should be the OLD image ID 

              #imageurl
              @imageurl =  @baseimageurl + @pathr  +tmpnewfilename
              
            else
              #unsuccessful resize - arguments will have been set such as image_ID etc
              #will end up sending back info on the original file 
            end
          else
          end
      end #end of adding to the database
    end #end of identity
  end
  
  def getimageurl(tmpimageid=0,tmpwidth=900,wm=0,blankimage=".jpg")
    if (tmpimageid.to_i > 0 )
      sql2 = ActiveRecord::Base.connection()
      getid = sql2.execute ("call getimage (#{tmpimageid},#{tmpwidth}) ;") 
      row = getid.fetch_hash
      
      if (row)
        @imageid   = tmpimageid
        @imagename     = row["image_name"]
        @imageheight   = row["height"]  
        @imagewidth    = row["width"] 
        @imagetype    = row["type"]  
        @imagesize    = row["size"] 
        @imagefilepath   = row["original_path"] 

        #URL isnt stored fully, so need to determine if @pathr or @patho is in the filepath, then alter as needed
        @imageurl =   @baseimageurl + @pathr +  File.basename(@imagefilepath)

        tmporiginal = row["original"]

        if (tmporiginal == "Y" || tmporiginal == 'y')
          @imageurl =   @baseimageurl + @patho +  File.basename(@imagefilepath)
        end
      else
        @imageurl = blankimage
      end
      # stored procedure seemed to disconnect afterwards - this prevents a command out of sync error 
      if (sql2.active? == false)
        sql2.reconnect! 
      end
    end
  end
end





 