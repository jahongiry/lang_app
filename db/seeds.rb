# Ensure there's at least one user in the database
user = User.first || User.create!(email: 'user@example.com', password: 'password', name: 'John', surname: 'Doe', teacher: true)

# Create a lesson for the first user
lesson = Lesson.create!(
  user: user,
  title: "Introduction to Biology",
  description: "A basic introduction to biological concepts.",
  completed: false,
  score: 0
)

# Create media items for the lesson
media_item1 = MediaItem.create!(
  lesson: lesson,
  media_type: "video",
  media_link: "https://example.com/video.mp4"
)

# Create multiple questions with answers for the first media item
MultipleQuestion.create!(
  media_item: media_item1,
  content: "What are the main organelles of a plant cell?",
  answers_attributes: [
    { content: "Nucleus", correct: false },
    { content: "Mitochondria", correct: false },
    { content: "Chloroplast", correct: true },
    { content: "Cell wall", correct: false }
  ]
)

MultipleQuestion.create!(
  media_item: media_item1,
  content: "What is the role of mitochondria?",
  answers_attributes: [
    { content: "Protein synthesis", correct: false },
    { content: "Photosynthesis", correct: false },
    { content: "Energy production", correct: true },
    { content: "DNA replication", correct: false }
  ]
)

# Create text question sets for the lesson
text_question_set = TextQuestionSet.create!(
  lesson: lesson,
  text: "Describe the process of photosynthesis."
)

# Add questions to the text question set
Question.create!(
  text_question_set: text_question_set,
  text: "What is the primary function of the chloroplast?"
)

Question.create!(
  text_question_set: text_question_set,
  text: "What are the reactants of photosynthesis?"
)

puts "Seeds created successfully!"
