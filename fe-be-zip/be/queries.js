const Pool = require('pg').Pool
const pool = new Pool({
  user: process.env.DB_USER || 'labadmin',
  host: process.env.DB_HOST || 'postgresql-server-nghiattr.postgres.database.azure.com',
  database: process.env.DB_NAME || 'postgres',
  password: process.env.DB_PASSWORD || 'H@Sh1CoR3!',
  port: 5432,
  ssl: true,
})


const getUsers = (request, response) => {
  
  pool.query('SELECT * FROM users', (error, results) => {
    if (error) {
      throw error
    }
    response.status(200).json(results.rows)
  })
}

module.exports = {
  getUsers
}
