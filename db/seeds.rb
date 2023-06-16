# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# TODO: create seeds for User (1 user, 1 admin),
#                        Profile
#                        Stations (4)
#                        Route (3?)
#                        CarriageType (2-3)
#                        Carriage (5-6)
#                        Trains (3?)
#                        Seats for carriages
#                        TrainStop (for each train on route)

User.create(email: "johndoe@gmail.com", password: "12345678", role: :admin, activated: true)