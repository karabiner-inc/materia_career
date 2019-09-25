defmodule Mix.Tasks.MateriaCareer.Gen.Migration do
  @shortdoc "Generates MateriaCareer's migration files."

  alias Mix.Tasks.Materia.Gen.Migration

  @migrations_file_path "priv/repo/migrations"
  @migration_module_path "deps/materia_career/lib/mix/templates"

  @doc false
  def run(args) do
    args
    |> Migration.setting_migration_module_path(@migration_module_path)
    |> Migration.create_migration_files(@migrations_file_path, "materia_career")
  end
end
