require 'active_record_lite'

# https://tomafro.net/2010/01/tip-relative-paths-with-file-expand-path
cats_db_file_name =
  File.expand_path(File.join(File.dirname(__FILE__), "cats.db"))
DBConnection.open(cats_db_file_name)

class Cat < SQLObject
  set_table_name("cats")
  set_attrs(:id, :name, :owner_id)
end

class Human < SQLObject
  set_table_name("humans")
  set_attrs(:id, :fname, :lname, :house_id)
end

p Human.find(1)
p Cat.find(1)
cat = Cat.find(2)
cat.name = "even newer newer named kitty"
cat.save

cat = Cat.new(name: "packy", owner_id: 1)
# p cat.new

p Human.all
p Cat.all

c = Cat.new(:name => "Packy", :owner_id => 1)
c.save # create
c.name = "packyness"
c.save # update
