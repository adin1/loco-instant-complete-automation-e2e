export async function loginUser(email: string, password: string) {
  try {
    const res = await fetch("http://localhost:3000/auth/login", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email, password }),
    });

    if (!res.ok) {
      throw new Error("Invalid credentials");
    }

    return await res.json();
  } catch (error) {
    console.error("Login error:", error);
    throw error;
  }
}
