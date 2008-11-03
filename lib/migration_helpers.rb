module MigrationHelpers
  
  def add_foreign_key(from_table, from_column, to_table)
    constraint_name = "fk_#{from_table}_#{from_column}"
  
    execute %{alter table #{from_table}
               add constraint #{constraint_name}
               foreign key (#{from_column})
               references #{to_table}(id)}
  end
  
  
  def remove_foreign_key(from_table, from_column)
    constraint_name = "fk_#{from_table}_#{from_column}"
  
    execute %{alter table #{from_table}
               drop foreign key #{constraint_name}}
  end
  
end