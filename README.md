# HybridBlog

To start the server on development environment:

  1. Install dependencies with `mix deps.get`
  2. Create and migrate our database with `mix ecto.setup`
  3. Install Node.js dependencies with `npm install` inside the `assets` directory
  4. Start Phoenix endpoint with `mix phx.server`

Then visit http://localhost:4000 from the browser.

To sign in with Google:

  1. Publish an OAuth 2.0 client ID and secret on [Google Cloud Console](https://console.cloud.google.com/apis/credentials).
  2. Add following lines to config/dev.exs:
     ```elixir
     config :hybrid_blog, :assent_providers,
       google: [
         client_id: "<YOUR APP'S CLIENT ID>",
         client_secret: "<YOUR APP'S SECRET>"
       ]
     ```
  3. Restart Phoenix endpoint
  4. Sign in with Google. The account signing in at this time will authorized as a administrative user.
  5. Run `mix run priv/repo/authorize_first_user.exs`.

Now the first user account can list and edit the created role.

To deploy onto the Gigalixir from GitHub repository:

  1. Create a Gigalixir app on the Gigalixir console.
  2. Create a Database for the app.
  3. Add environment variables to the Gigalixir app:
     * `GOOGLE_CLIENT_ID`: OAuth client ID for production (or staging).
     * `GOOGLE_CLIENT_SECRET`: OAuth client secret for production (or staging).
  4. Add secrets to the GitHub repository:
     * `GIGALIXIR_APP_NAME`
     * `GIGALIXIR_EMAIL`
     * `GIGALIXIR_PASSWORD`
  5. Create the `dev` branch or create and merge a pull request to the `dev` branch with a project version incrementation in the `mix.exs`.
  6. The GitHub Actions workflow automatically runs a deployment.
  7. After deployment, sign in with your OAuth account.
  8. Run a distillery command `gigalixir ps:distillery authorize_first_user`.

Then your account can list and edit the role as you could on the development enviroment.

  * The GitHub Actions workflow is designed to be used with following condition:
    - The default branch is `dev`.
    - The deployed branch is `master`.
    - Tests runs when the pull request to the `dev` is created or the `dev` branch is updated.
    - If the project version of `mix.exs` is updated on `dev` branch, then it will be merged to the `master` and deployed to the Gigalixir.
