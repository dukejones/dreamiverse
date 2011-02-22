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

ActiveRecord::Schema.define(:version => 20110222015423) do

  create_table "authentications", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "default_sharing", :default => false
  end

  add_index "authentications", ["provider", "uid"], :name => "index_authentications_on_provider_and_uid"
  add_index "authentications", ["user_id"], :name => "index_authentications_on_user_id"

  create_table "black_list_words", :force => true do |t|
    t.string "word"
    t.string "kind"
  end

  add_index "black_list_words", ["word"], :name => "index_black_list_words_on_word"

  create_table "comments", :force => true do |t|
    t.text     "body"
    t.integer  "user_id"
    t.integer  "entry_id"
    t.integer  "image_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dictionaries", :force => true do |t|
    t.string   "name"
    t.string   "attribution"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "emotions", :force => true do |t|
    t.string "name"
  end

  create_table "entries", :force => true do |t|
    t.text     "body"
    t.string   "title"
    t.string   "tags"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",          :default => "Dream"
    t.integer  "sharing_level"
  end

  create_table "entries_images", :id => false, :force => true do |t|
    t.integer "entry_id"
    t.integer "image_id"
  end

  create_table "entry_accesses", :force => true do |t|
    t.integer "user_id"
    t.integer "entry_id"
    t.integer "level",    :default => 20
  end

  create_table "follows", :force => true do |t|
    t.integer "user_id"
    t.integer "following_id"
  end

  add_index "follows", ["user_id", "following_id"], :name => "index_follows_on_user_id_and_following_id", :unique => true

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

  create_table "links", :force => true do |t|
    t.string   "url",        :null => false
    t.string   "title",      :null => false
    t.integer  "owner_id"
    t.string   "owner_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "links", ["owner_id", "owner_type"], :name => "index_links_on_owner_id_and_owner_type"

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
    t.integer "user_id"
    t.integer "position",   :default => 0
    t.string  "kind",       :default => "custom"
    t.integer "intensity"
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
    t.string   "phone"
    t.string   "skype"
    t.integer  "default_location_id"
    t.integer  "default_sharing_level", :default => 200
    t.boolean  "follow_authorization",  :default => false
    t.boolean  "ubiquity",              :default => false, :null => false
    t.integer  "auth_level",            :default => 10
  end

  add_index "users", ["seed_code"], :name => "index_users_on_seed_code"
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

  create_table "view_preferences", :force => true do |t|
    t.string   "theme"
    t.integer  "image_id"
    t.integer  "viewable_id"
    t.string   "viewable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "bedsheet_attachment", :default => "scroll"
  end

  add_index "view_preferences", ["viewable_id", "viewable_type"], :name => "index_view_preferences_on_viewable_id_and_viewable_type"

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
    t.integer "user",      :limit => 8
    t.string  "user_type"
  end

  create_table "words", :force => true do |t|
    t.string  "name"
    t.text    "definition"
    t.string  "attribution"
    t.integer "dictionary_id"
  end

  add_index "words", ["name"], :name => "index_words_on_name"

end
