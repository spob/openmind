module MigrationHelpers
  
  def add_foreign_key(from_table, from_column, to_table)
    name = constraint_name from_table, from_column
    
    execute %{ALTER TABLE #{from_table} ADD CONSTRAINT #{name} FOREIGN KEY (#{from_column}) REFERENCES #{to_table}(id)}
  end
  
  
  def remove_foreign_key(from_table, from_column)
    name = constraint_name from_table, from_column
    
    execute %{ALTER TABLE #{from_table} DROP FOREIGN KEY #{name}}
  end
  
  private
  
  def constraint_name from_table, from_column
    "fk_#{from_table}_#{from_column}"
  end
  
end