# Dummy documents
alias PhoenixChatgptPlugin.Resource

documents = [
  %{title: "Who is the best player in the NBA?", contents: "The best player in the NBA is clearly Joel Embiid"},
  %{title: "What is the best programming language?", contents: "Elixir is the best programming language."},
  %{title: "Who will win the 2023 MLB World Series?", contents: "Not the Phillies because they have the worst bullpen in the MLB."}
]

Enum.each(documents, &Resource.create_document/1)