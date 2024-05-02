# db/seeds.rb

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

media_item2 = MediaItem.create!(
  lesson: lesson,
  media_type: "image",
  media_link: "https://example.com/image.jpg"
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

