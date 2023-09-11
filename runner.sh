const fs = require("fs");
const config = require('config');

// Fetch configuration parameters
const host = config.get("server.host");
const user = config.get("server.user");
const password = config.get("server.password");
const database = config.get("server.database");

const gmailuser = config.get("gmail.user");
const gmailpassword = config.get("gmail.password");

// Import the pg library
const { Client } = require('pg');

// Create connection
const connectionConfig = {
	host : host,
	user : user,
	password : password,
	database : database,
	port: 5432
};

// Create a new PostgreSQL client instance
const con = new Client(connectionConfig);

con.on('error', (err) => {
  console.error('PostgreSQL connection error:', err.message);
    // Handle the error here and display it to the user, e.g., through a response to an HTTP request.
});

// Run SQL query and return response as a simple table
function runQuery(sql) {
	console.log(sql)
	var response = '';
	return new Promise(resolve => {
con.connect()
  .then(() => {
    console.log('Connected to PostgreSQL database');
		



		con.query(sql, (err,rows) => {
			if(err) throw err;
				var objToJson = rows;
				for (var key in rows) {
					for (var val in rows[key]) {
						response += rows[key][val] + "\t";
					}
					response += "\n";
				}
				console.log(response);
				resolve(response);
			});
  })
  .catch((err) => {
    console.error('Error connecting to PostgreSQL:', err.message);
  });
	});
}

// Read input File to get SQL
async function processFile(inputFile) {
	const buffer = fs.readFileSync(inputFile);
	const sql = buffer.toString();
	console.log('running ' + inputFile)
	result = await runQuery(sql);

	return new Promise(resolve => {
		resolve(result);
	})
}

// Make async function main to wait for processing to complete before exiting
(async function main() {
	if (process.argv.length <= 2) {
		console.error('Expected at least one argument! node process.sh scripts/filename.sql "subject"');
		process.exit(1);
	}

	const sqlResult = await processFile(__dirname + "/" + process.argv[2]);
	console.log(sqlResult);

	process.exit();
})()
