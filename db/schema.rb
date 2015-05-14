# encoding: UTF-8
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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141201182318) do

  create_table "authentications", force: :cascade do |t|
    t.string   "provider",        limit: 255
    t.string   "uid",             limit: 255
    t.integer  "user_id",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "default_sharing", limit: 1,   default: false
  end

  add_index "authentications", ["provider", "uid"], name: "index_authentications_on_provider_and_uid", using: :btree
  add_index "authentications", ["user_id"], name: "index_authentications_on_user_id", using: :btree

  create_table "blacklist_words", force: :cascade do |t|
    t.string "word", limit: 255
    t.string "kind", limit: 255
  end

  add_index "blacklist_words", ["word"], name: "index_black_list_words_on_word", using: :btree

  create_table "books", force: :cascade do |t|
    t.string   "title",            limit: 255
    t.integer  "user_id",          limit: 4
    t.integer  "cover_image_id",   limit: 4
    t.string   "color",            limit: 255
    t.integer  "sharing_level",    limit: 4
    t.integer  "commenting_level", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: :cascade do |t|
    t.text     "body",       limit: 65535
    t.integer  "user_id",    limit: 4
    t.integer  "entry_id",   limit: 4
    t.integer  "image_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", force: :cascade do |t|
    t.string "iso2", limit: 2
    t.string "iso3", limit: 3
    t.string "name", limit: 255
  end

  add_index "countries", ["iso2"], name: "index_countries_on_iso2", using: :btree

  create_table "dictionaries", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "attribution", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "emotions", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "entries", force: :cascade do |t|
    t.text     "body",                 limit: 65535
    t.string   "title",                limit: 255
    t.string   "tags",                 limit: 255
    t.integer  "user_id",              limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",                 limit: 255,   default: "dream"
    t.integer  "sharing_level",        limit: 4
    t.datetime "dreamed_at"
    t.integer  "main_image_id",        limit: 4
    t.integer  "location_id",          limit: 4
    t.string   "book_list",            limit: 255
    t.integer  "starlight",            limit: 4,     default: 0
    t.integer  "cumulative_starlight", limit: 4,     default: 0
    t.integer  "uniques",              limit: 4,     default: 0
    t.integer  "new_comment_count",    limit: 4,     default: 0
    t.integer  "book_id",              limit: 4
  end

  create_table "entries_images", id: false, force: :cascade do |t|
    t.integer "entry_id", limit: 4
    t.integer "image_id", limit: 4
  end

  create_table "entry_accesses", force: :cascade do |t|
    t.integer "user_id",  limit: 4
    t.integer "entry_id", limit: 4
    t.integer "level",    limit: 4, default: 20
  end

  create_table "follows", force: :cascade do |t|
    t.integer "user_id",      limit: 4
    t.integer "following_id", limit: 4
  end

  add_index "follows", ["user_id", "following_id"], name: "index_follows_on_user_id_and_following_id", unique: true, using: :btree

  create_table "hits", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "ip_address", limit: 15
    t.string   "url_path",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "hits", ["url_path", "ip_address"], name: "index_hits_on_url_path_and_ip_address", using: :btree

  create_table "images", force: :cascade do |t|
    t.string   "section",           limit: 255
    t.string   "category",          limit: 255
    t.string   "genre",             limit: 255
    t.string   "title",             limit: 255
    t.string   "artist",            limit: 255
    t.string   "album",             limit: 255
    t.string   "location",          limit: 255
    t.integer  "year",              limit: 4
    t.text     "notes",             limit: 65535
    t.integer  "uploaded_by_id",    limit: 4
    t.string   "geotag",            limit: 255
    t.text     "tags",              limit: 65535
    t.boolean  "public",            limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "format",            limit: 10
    t.integer  "size",              limit: 4
    t.integer  "width",             limit: 4
    t.integer  "height",            limit: 4
    t.string   "original_filename", limit: 255
    t.string   "source_url",        limit: 255
    t.boolean  "enabled",           limit: 1,     default: false
    t.string   "attribution",       limit: 255
    t.string   "image_path",        limit: 255
  end

  create_table "links", force: :cascade do |t|
    t.string   "url",        limit: 255, null: false
    t.string   "title",      limit: 255
    t.integer  "owner_id",   limit: 4
    t.string   "owner_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "links", ["owner_id", "owner_type"], name: "index_links_on_owner_id_and_owner_type", using: :btree

  create_table "starlights", force: :cascade do |t|
    t.integer  "entity_id",   limit: 4
    t.string   "entity_type", limit: 255
    t.integer  "value",       limit: 4,   default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", force: :cascade do |t|
    t.integer "entry_id",   limit: 4
    t.string  "entry_type", limit: 255, default: "Dream"
    t.integer "noun_id",    limit: 4
    t.string  "noun_type",  limit: 255, default: "What"
    t.integer "position",   limit: 4,   default: 0
    t.string  "kind",       limit: 255, default: "custom", null: false
    t.integer "intensity",  limit: 4
  end

  create_table "users", force: :cascade do |t|
    t.string   "username",              limit: 255
    t.string   "name",                  limit: 255
    t.string   "email",                 limit: 255
    t.integer  "image_id",              limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password",    limit: 255
    t.string   "seed_code",             limit: 255
    t.string   "phone",                 limit: 255
    t.string   "skype",                 limit: 255
    t.integer  "default_location_id",   limit: 4
    t.integer  "default_sharing_level", limit: 4
    t.boolean  "follow_authorization",  limit: 1,   default: false
    t.boolean  "ubiquity",              limit: 1,   default: false,        null: false
    t.integer  "auth_level",            limit: 4,   default: 0
    t.integer  "starlight",             limit: 4,   default: 0
    t.integer  "cumulative_starlight",  limit: 4,   default: 0
    t.string   "stream_filter",         limit: 255, default: "--- {}\n\n"
    t.string   "default_landing_page",  limit: 255, default: "stream"
    t.string   "default_entry_type",    limit: 255, default: "dream"
  end

  add_index "users", ["seed_code"], name: "index_users_on_seed_code", using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "users_wheres", id: false, force: :cascade do |t|
    t.integer "user_id",  limit: 4
    t.integer "where_id", limit: 4
  end

  add_index "users_wheres", ["user_id", "where_id"], name: "index_users_wheres_on_user_id_and_where_id", using: :btree

  create_table "view_preferences", force: :cascade do |t|
    t.string   "theme",               limit: 255
    t.integer  "image_id",            limit: 4
    t.integer  "viewable_id",         limit: 4
    t.string   "viewable_type",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "bedsheet_attachment", limit: 255, default: "scroll"
    t.string   "font_size",           limit: 255, default: "medium"
    t.string   "menu_style",          limit: 255, default: "float"
  end

  add_index "view_preferences", ["viewable_id", "viewable_type"], name: "index_view_preferences_on_viewable_id_and_viewable_type", using: :btree

  create_table "whats", force: :cascade do |t|
    t.string  "name",                 limit: 255
    t.integer "starlight",            limit: 4,   default: 0
    t.integer "cumulative_starlight", limit: 4,   default: 0
    t.integer "image_id",             limit: 4
  end

  create_table "wheres", force: :cascade do |t|
    t.string  "name",      limit: 255
    t.string  "city",      limit: 255
    t.string  "province",  limit: 255
    t.string  "country",   limit: 255
    t.decimal "latitude",              precision: 10, scale: 6
    t.decimal "longitude",             precision: 10, scale: 6
  end

  create_table "whos", force: :cascade do |t|
    t.string  "name",      limit: 255
    t.integer "user",      limit: 8
    t.string  "user_type", limit: 255
  end

  create_table "words", force: :cascade do |t|
    t.string  "name",          limit: 255
    t.text    "definition",    limit: 65535
    t.string  "attribution",   limit: 255
    t.integer "dictionary_id", limit: 4
  end

  add_index "words", ["name"], name: "index_words_on_name", using: :btree

end
