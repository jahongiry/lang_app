# Documentation

\*\* Users
GET /api/v1/users

GET /api/v1/users/:id

POST /api/v1/users

```
{
    "user": {
        "email": "example@example.com",
        "password": "yourpassword",
        "name": "John",
        "surname": "Doe"
    }
}

```

POST /api/v1/login

```
{
  "email": "teacher@gmail.com",
  "password": "teacher123"
}
```

PATCH/PUT /api/v1/users/:id

DELETE /api/v1/users/:id

teacher:
email = 'teacher@gmail.com'
password = 'teacher123'

\*\* Lessons

GET /api/v1/lessons

GET /api/v1/lessons/:id

POST /api/v1/lessons

{
"lesson": {
"index": 1,
"title": "Introduction to Ruby on Rails",
"description": "This lesson covers the basics of Ruby on Rails framework.",
"completed": false,
"score": 0
}
}

PATCH/PUT /api/v1/lessons/:id

DELETE /api/v1/lessons/:id

\*\* Reading

POST /api/v1/lessons/1/text_question_sets

{
"text_question_set": {
"text": "Your text here",
"lesson_id": 1
}
}

POST /api/v1/questions

{
"question": {
"text": "What is the capital of France?",
"text_question_set_id": 1
}
}

POST /api/v1/user_answers

{
"user_answer": {
"text": "This is my answer",
"question_id": 1
}
}

POST /api/v1/user_answers/{user_answer_id}/answer_feedback

{
"answer_feedback": {
"score": 10,
"comment": "Great answer!"
}
}

\*\* Media

GET /api/v1/lessons/:lesson_id/media_items/:id

POST /api/v1/lessons/:lesson_id/media_items

PATCH/PUT /api/v1/lessons/:lesson_id/media_items/:id

DELETE /api/v1/lessons/:lesson_id/media_items/:id

GET /api/v1/lessons/:lesson_id/media_items/:media_item_id/multiple_questions

POST /api/v1/lessons/:lesson_id/media_items/:media_item_id/multiple_questions

PATCH/PUT /api/v1/lessons/:lesson_id/media_items/:media_item_id/multiple_questions/:id

DELETE /api/v1/lessons/:lesson_id/media_items/:media_item_id/multiple_questions/:id
