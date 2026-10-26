import {  useState } from "react";
import type { SubmitEvent } from "react";
import { useNavigate } from "react-router-dom";
import { setToken } from "../auth/auth";
import "../styles/Login.css";
import backgroundImg from '../assets/background.jpg';


export default function Login() {
    const navigate = useNavigate();

    const [username, setUsername] = useState("");
    const [password, setPassword] = useState("");
    const [error, setError] = useState("");

    async function handleSubmit(event: SubmitEvent) {
        event.preventDefault();
        setError("");

        try {
            const response = await fetch("/api/login", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify({
                    username,
                    password,
                }),
            });
            const data = await response.json();
            if (!response.ok) {
                setError(data.mensaje);
                return;
            }


            setToken(data.token);

            navigate("/", { replace: true });
        } catch (error) {
            setError("Could not connect to the server");
        }
    }

    return (
        <main className="login-page">
            <div className="login-card">
                <h1>Login</h1>

                <form onSubmit={handleSubmit}>
                    <div className="form-group">
                        <label htmlFor="username">Username</label>
                        <input
                            id="username"
                            type="text"
                            value={username}
                            onChange={(e) => setUsername(e.target.value)}
                            autoComplete="username"
                            required
                        />
                    </div>

                    <div className="form-group">
                        <label htmlFor="password">Password</label>
                        <input
                            id="password"
                            type="password"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            autoComplete="current-password"
                            required
                        />
                    </div>

                    {error && <p className="login-error">{error}</p>}

                    <button type="submit">
                        Login
                    </button>
                </form>
            </div>
        </main>
    );
}