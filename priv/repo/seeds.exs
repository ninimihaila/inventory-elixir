# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Inventory.Repo.insert!(%Inventory.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Inventory.Repo
alias Inventory.Items.Item
alias Inventory.Accounts.User

%User{
  email: "test@ex.com",
  hashed_password: Bcrypt.hash_pwd_salt("pass")
} |> Repo.insert!()


for _i <- 1..100 do
  %Item{
    entry_date: Faker.Date.backward(10),
    expiry_date: Faker.Date.forward(30),
    name: Faker.Food.ingredient(),
  } |> Repo.insert!()
end
