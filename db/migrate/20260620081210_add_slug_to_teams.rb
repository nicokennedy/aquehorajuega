class AddSlugToTeams < ActiveRecord::Migration[7.1]
  def up
    add_column :teams, :slug, :string

    # Backfill con el MISMO parameterize que usan los links (to_param),
    # así la URL generada y el lookup coinciden (antes los acentos/ñ
    # daban 404: el link decía "paises-bajos" pero la búsqueda usaba
    # REPLACE(name) -> "países-bajos").
    Team.reset_column_information
    Team.find_each do |team|
      team.update_column(:slug, team.name.to_s.parameterize)
    end

    add_index :teams, :slug
  end

  def down
    remove_index :teams, :slug
    remove_column :teams, :slug
  end
end
