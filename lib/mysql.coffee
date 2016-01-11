mysql = require 'mysql'
connection = mysql.createConnection
  host     : 'localhost',
  user     : 'root',
  password : '',
  database : 'sharkeyfootytipping'
connection.connect() 
module.exports = connection
