# Seed multiple questions with answers

# Ensure there's at least one user in the database
user = User.first || User.create!(email: 'user@example.com', password: 'password', name: 'John', surname: 'Doe', teacher: true)

# # Create a lesson for the first user
# lesson = Lesson.create!(
#   user: user,
#   title: "Advanced Biology",
#   description: "An in-depth exploration of biological systems.",
#   completed: false,
#   score: 0
# )

# # Create a media item for the lesson
# media_item1 = MediaItem.create!(
#   lesson: lesson,
#   media_type: "video",
#   media_link: "https://example.com/advanced_bio.mp4"
# )

# # Define a set of questions with a mix of correct and incorrect answers
# questions_with_answers = [
#   {
#     question: "What structures are involved in photosynthesis?",
#     answers: [
#       { content: "Chloroplasts", correct: true },
#       { content: "Mitochondria", correct: false },
#       { content: "Ribosomes", correct: false },
#       { content: "Nucleus", correct: false }
#     ]
#   },
#   {
#     question: "Which organ is primarily responsible for oxygen exchange in mammals?",
#     answers: [
#       { content: "Heart", correct: false },
#       { content: "Lungs", correct: true },
#       { content: "Liver", correct: false },
#       { content: "Kidneys", correct: false }
#     ]
#   },
#   {
#     question: "What is the main function of the liver?",
#     answers: [
#       { content: "Digestion", correct: false },
#       { content: "Detoxification", correct: true },
#       { content: "Insulin production", correct: false },
#       { content: "Blood filtration", correct: true }
#     ]
#   }
# ]

# # Create multiple questions and their answers in the database
# questions_with_answers.each do |qa|
#   multiple_question = MultipleQuestion.create!(
#     media_item: media_item1,
#     content: qa[:question]
#   )

#   qa[:answers].each do |answer|
#     Answer.create!(
#       multiple_question: multiple_question,
#       content: answer[:content],
#       correct: answer[:correct]
#     )
#   end
# end

# puts "Seeds created successfully!"
