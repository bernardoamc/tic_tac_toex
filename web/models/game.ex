defmodule TicTacToex.Game do
  use TicTacToex.Web, :model

  @primary_key false

  schema "games" do
    field :room, :string
    field :player, :string
  end

  @required_fields ~w(room player)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
      |> cast(params, @required_fields, @optional_fields)
      |> validate_length(:room, min: 4, max: 20)
      |> validate_length(:player, min: 4, max: 20)
  end
end
