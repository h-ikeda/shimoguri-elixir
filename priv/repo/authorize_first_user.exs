alias HybridBlog.Repo
alias HybridBlog.Accounts.User
alias HybridBlog.Accounts.Role
import Ecto.Query, only: [from: 2]
import Ecto.Changeset, only: [change: 1, put_assoc: 3]

[user] = Repo.all(from User, preload: :roles)
role = Repo.insert!(%Role{name: "Admin", permissions: ["list_roles", "edit_roles"]})
change(user) |> put_assoc(:roles, [role | user.roles]) |> Repo.update!()
