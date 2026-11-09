import { apiRequest } from "../../api/client";
import type {loginResponse} from "../../types/loginResponse.tsx";

export const login = (username: string, password: string) => 
    apiRequest<loginResponse>("/login", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify({
                    username,
                    password,
                }),
            });

