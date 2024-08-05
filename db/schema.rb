# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_08_05_034840) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "answer_feedbacks", force: :cascade do |t|
    t.integer "score"
    t.text "comment"
    t.bigint "user_answer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "details"
    t.index ["user_answer_id"], name: "index_answer_feedbacks_on_user_answer_id"
  end

  create_table "answers", force: :cascade do |t|
    t.text "content"
    t.boolean "correct"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "media_item_id", default: 1, null: false
    t.bigint "multiple_question_id"
    t.index ["media_item_id"], name: "index_answers_on_media_item_id"
    t.index ["multiple_question_id"], name: "index_answers_on_multiple_question_id"
  end

  create_table "lessons", force: :cascade do |t|
    t.integer "index"
    t.string "title"
    t.text "description"
    t.integer "score"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["index"], name: "index_lessons_on_index"
    t.index ["user_id"], name: "index_lessons_on_user_id"
  end

  create_table "media_items", force: :cascade do |t|
    t.bigint "lesson_id", null: false
    t.string "media_type"
    t.string "media_link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_id"], name: "index_media_items_on_lesson_id"
  end

  create_table "multiple_questions", force: :cascade do |t|
    t.bigint "media_item_id", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["media_item_id"], name: "index_multiple_questions_on_media_item_id"
  end

  create_table "questions", force: :cascade do |t|
    t.text "text"
    t.bigint "text_question_set_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["text_question_set_id"], name: "index_questions_on_text_question_set_id"
  end

  create_table "test_results", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "correct_count"
    t.integer "total_questions"
    t.float "correct_percentage"
    t.float "wrong_percentage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "media_item_id", default: 1, null: false
    t.bigint "multiple_question_id"
    t.index ["media_item_id"], name: "index_test_results_on_media_item_id"
    t.index ["multiple_question_id"], name: "index_test_results_on_multiple_question_id"
    t.index ["user_id"], name: "index_test_results_on_user_id"
  end

  create_table "text_question_sets", force: :cascade do |t|
    t.text "text"
    t.bigint "lesson_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_id"], name: "index_text_question_sets_on_lesson_id"
  end

  create_table "translations", force: :cascade do |t|
    t.bigint "media_item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "array_of_objects", default: "[]"
    t.index ["media_item_id"], name: "index_translations_on_media_item_id"
  end

  create_table "user_answer_multiples", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "answer_id", null: false
    t.bigint "multiple_question_id", null: false
    t.boolean "correct"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["answer_id"], name: "index_user_answer_multiples_on_answer_id"
    t.index ["multiple_question_id"], name: "index_user_answer_multiples_on_multiple_question_id"
    t.index ["user_id"], name: "index_user_answer_multiples_on_user_id"
  end

  create_table "user_answers", force: :cascade do |t|
    t.text "text"
    t.bigint "user_id", null: false
    t.bigint "question_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_user_answers_on_question_id"
    t.index ["user_id"], name: "index_user_answers_on_user_id"
  end

  create_table "user_lessons", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "lesson_id", null: false
    t.integer "score"
    t.boolean "completed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_id"], name: "index_user_lessons_on_lesson_id"
    t.index ["user_id"], name: "index_user_lessons_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "teacher"
    t.string "name"
    t.string "surname"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "answer_feedbacks", "user_answers"
  add_foreign_key "answers", "media_items"
  add_foreign_key "answers", "multiple_questions"
  add_foreign_key "lessons", "users"
  add_foreign_key "media_items", "lessons"
  add_foreign_key "multiple_questions", "media_items"
  add_foreign_key "questions", "text_question_sets"
  add_foreign_key "test_results", "media_items"
  add_foreign_key "test_results", "users"
  add_foreign_key "text_question_sets", "lessons"
  add_foreign_key "translations", "media_items"
  add_foreign_key "user_answer_multiples", "answers"
  add_foreign_key "user_answer_multiples", "multiple_questions"
  add_foreign_key "user_answer_multiples", "users"
  add_foreign_key "user_answers", "questions"
  add_foreign_key "user_answers", "users"
  add_foreign_key "user_lessons", "lessons"
  add_foreign_key "user_lessons", "users"
end
