if ::ActiveRecord::Base.connection_config[:adapter] == 'sqlite3'
  if c = ::ActiveRecord::Base.connection
    c.execute 'PRAGMA main.journal_mode=WAL;'
  end
end