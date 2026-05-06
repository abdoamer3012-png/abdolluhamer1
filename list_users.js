import sql from "./src/app/api/utils/sql.js";

async function listUsers() {
  try {
    const users = await sql`SELECT * FROM users`;
    console.log(JSON.stringify(users, null, 2));
  } catch (e) {
    console.error(e);
  }
}

listUsers();
