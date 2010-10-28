class PopulateReleaseMapHistory < ActiveRecord::Migration
  def self.up
    sql1 = 
<<-eos
    insert into serial_number_release_map_histories
     (action,
     serial_number_release_map_id,
     created_at,
     updated_at)
    select 'ADD',
    id,
    created_at,
    created_at
    from serial_number_release_maps
eos
    sql2 = 
<<-eos
    insert into serial_number_release_map_histories
     (action,
     serial_number_release_map_id,
     created_at,
     updated_at)
    select 'REMOVE',
    id,
    disabled_at,
    disabled_at
    from serial_number_release_maps
    where disabled_at is not null
eos
    execute(sql1)
    execute(sql2)
  end
  
  def self.down
    SerialNumberReleaseMapHistory.delete_all 
  end
end
