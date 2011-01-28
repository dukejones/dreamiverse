# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110128205955) do

  create_table "authentications", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authentications", ["provider", "uid"], :name => "index_authentications_on_provider_and_uid"

  create_table "dreams", :force => true do |t|
    t.text     "body"
    t.string   "title"
    t.string   "tags"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friendships", :force => true do |t|
    t.integer "user_id"
    t.integer "friend_id"
    t.boolean "pending",   :default => true
    t.boolean "blocked",   :default => false
  end

  add_index "friendships", ["user_id", "friend_id"], :name => "index_friendships_on_user_id_and_friend_id", :unique => true

  create_table "hits", :force => true do |t|
    t.integer  "user_id"
    t.string   "ip_address", :limit => 15
    t.string   "url_path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", :force => true do |t|
    t.string   "section"
    t.string   "category"
    t.string   "genre"
    t.string   "title"
    t.string   "artist"
    t.string   "album"
    t.string   "location"
    t.integer  "year"
    t.text     "notes"
    t.integer  "uploaded_by"
    t.string   "geotag"
    t.text     "tags"
    t.boolean  "public"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "format",            :limit => 10
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.string   "original_filename"
    t.string   "source_url"
    t.boolean  "enabled",                         :default => false
    t.string   "attribution"
  end

  create_table "starlights", :force => true do |t|
    t.integer  "entity_id"
    t.string   "entity_type"
    t.integer  "value",       :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", :force => true do |t|
    t.integer "entry_id"
    t.string  "entry_type", :default => "Dream"
    t.integer "noun_id"
    t.string  "noun_type",  :default => "What"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "name"
    t.string   "email"
    t.integer  "image_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password"
    t.string   "seed_code"
  end

  create_table "whats", :force => true do |t|
    t.string "name"
  end

  create_table "wheres", :force => true do |t|
    t.string  "name"
    t.string  "city"
    t.string  "province"
    t.string  "country"
    t.decimal "latitude",  :precision => 6, :scale => 0
    t.decimal "longitude", :precision => 6, :scale => 0
  end

  create_table "whos", :force => true do |t|
    t.string  "name"
    t.string  "source"
    t.integer "user",   :limit => 8
  end

end
