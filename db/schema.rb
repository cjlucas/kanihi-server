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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130824130000) do

  create_table "album_artists", :force => true do |t|
    t.string   "name",            :null => false
    t.string   "sort_name"
    t.string   "uuid",            :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "name_normalized"
  end

  create_table "albums", :force => true do |t|
    t.string   "name"
    t.string   "uuid",            :null => false
    t.integer  "album_artist_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "name_normalized"
    t.integer  "total_discs"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "discs", :force => true do |t|
    t.integer  "num"
    t.string   "subtitle"
    t.integer  "total_tracks"
    t.string   "uuid",         :null => false
    t.integer  "album_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "genres", :force => true do |t|
    t.string   "name"
    t.string   "uuid",            :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "name_normalized"
  end

  create_table "images", :force => true do |t|
    t.string   "type"
    t.string   "description"
    t.string   "checksum"
    t.integer  "size"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "images_tracks", :id => false, :force => true do |t|
    t.integer "track_id"
    t.integer "image_id"
  end

  add_index "images_tracks", ["image_id"], :name => "index_images_tracks_on_image_id"
  add_index "images_tracks", ["track_id"], :name => "index_images_tracks_on_track_id"

  create_table "settings", :force => true do |t|
    t.string   "keyname",      :limit => 64,                        :null => false
    t.text     "value"
    t.string   "value_format", :limit => 64,  :default => "string"
    t.string   "name",         :limit => 64
    t.string   "description",  :limit => 512
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
  end

  create_table "sources", :force => true do |t|
    t.string   "location"
    t.integer  "source_type"
    t.datetime "last_scanned_at"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.integer  "scan_interval",   :default => 86400
    t.boolean  "scanning",        :default => false
  end

  create_table "sources_tracks", :id => false, :force => true do |t|
    t.integer "source_id"
    t.integer "track_id"
  end

  add_index "sources_tracks", ["source_id"], :name => "index_sources_tracks_on_source_id"
  add_index "sources_tracks", ["track_id"], :name => "index_sources_tracks_on_track_id"

  create_table "track_artists", :force => true do |t|
    t.string   "name",            :null => false
    t.string   "sort_name"
    t.string   "uuid",            :null => false
    t.integer  "track_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "name_normalized"
  end

  create_table "tracks", :force => true do |t|
    t.string   "name"
    t.string   "subtitle"
    t.integer  "num"
    t.datetime "date"
    t.datetime "original_date"
    t.string   "group"
    t.string   "lyrics"
    t.string   "composer"
    t.string   "mood"
    t.boolean  "compilation"
    t.string   "comment"
    t.integer  "duration"
    t.datetime "mtime"
    t.integer  "size"
    t.string   "location"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "uuid"
    t.integer  "filesystem_id"
    t.integer  "disc_id"
    t.integer  "genre_id"
    t.integer  "track_artist_id"
  end

  add_index "tracks", ["location"], :name => "index_tracks_on_location"
  add_index "tracks", ["updated_at"], :name => "index_tracks_on_updated_at"
  add_index "tracks", ["uuid"], :name => "tracks_uuid_idx", :unique => true

end
