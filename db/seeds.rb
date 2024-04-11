# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
# db/seeds.rb

# Create items
Item.create([
	{ item_type: 'book', genre: 'comedy', title: 'Funny Book', isbn: '1234567890' },
	{ item_type: 'book', genre: 'crime', title: 'Mystery Book', isbn: '2345678901' },
	{ item_type: 'magazine', genre: 'comedy', title: 'Comedy Magazine', isbn: '3456789012' },
	{ item_type: 'magazine', genre: 'crime', title: 'Crime Magazine', isbn: '4567890123' }
])

# Create users
User.create([
  { name: 'User 1', email: 'user1@example.com', age: 16 },
  { name: 'User 2', email: 'user2@example.com', age: 20 }
])