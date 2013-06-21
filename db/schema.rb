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

ActiveRecord::Schema.define(:version => 20130620000000) do

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

  create_table "sources", :force => true do |t|
    t.string   "location"
    t.integer  "source_type"
    t.datetime "last_scanned_at"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "sources_tracks", :id => false, :force => true do |t|
    t.integer "source_id"
    t.integer "track_id"
  end

  create_table "tracks", :force => true do |t|
    t.string   "track_name"
    t.string   "subtitle"
    t.integer  "track_num"
    t.integer  "track_total"
    t.string   "track_artist"
    t.string   "track_artist_sort_order"
    t.string   "album_artist"
    t.string   "album_artist_sort_order"
    t.string   "album_name"
    t.string   "genre"
    t.datetime "date"
    t.datetime "original_date"
    t.integer  "disc_num"
    t.integer  "disc_total"
    t.string   "disc_subtitle"
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
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "tracks", ["location"], :name => "index_tracks_on_location"

end
