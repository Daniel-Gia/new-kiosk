import NextAuth from "next-auth";
import CredentialsProvider from "next-auth/providers/credentials";
import { readFile } from "node:fs/promises";
import path from "node:path";
import bcrypt from "bcryptjs";

export const runtime = "nodejs";

type AuthFile = {
    username: string;
    passwordHash: string;
};

const AUTH_FILE_PATH =
    process.env.AUTH_FILE ?? path.join(process.cwd(), "..", "settings", "auth.json");

const readAuthFile = async (): Promise<AuthFile | null> => {
    try {
        const raw = await readFile(AUTH_FILE_PATH, "utf8");
        const parsed = JSON.parse(raw) as Partial<AuthFile>;
        if (typeof parsed.username !== "string" || typeof parsed.passwordHash !== "string") {
            return null;
        }
        return { username: parsed.username, passwordHash: parsed.passwordHash };
    } catch {
        return null;
    }
};

const handler = NextAuth({
    secret: process.env.NEXTAUTH_SECRET,
    session: { strategy: "jwt" },
    pages: { signIn: "/login" },
    providers: [
        CredentialsProvider({
            name: "Credentials",
            credentials: {
                username: { label: "Username", type: "text" },
                password: { label: "Password", type: "password" },
            },
            async authorize(credentials) {
                const username = (credentials?.username ?? "").toString();
                const password = (credentials?.password ?? "").toString();

                const auth = await readAuthFile();
                if (!auth) return null;

                if (username !== auth.username) return null;

                const ok = await bcrypt.compare(password, auth.passwordHash);
                if (!ok) return null;

                return { id: auth.username, name: auth.username };
            },
        }),
    ],
});

export { handler as GET, handler as POST };
