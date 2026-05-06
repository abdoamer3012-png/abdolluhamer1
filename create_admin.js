import sql from "./src/app/api/utils/sql.js";

async function createAdmin() {
  try {
    await sql`
      INSERT INTO users (name, email, password, role)
      VALUES ('Admin', 'admin@nasr.com', 'admin123', 'admin')
      ON CONFLICT (email) DO UPDATE SET role = 'admin'
    `;
    console.log("Admin created/updated successfully");
  } catch (e) {
    console.error(e);
  }
}

createAdmin();
