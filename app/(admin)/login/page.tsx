import { login } from "./actions";

export default function LoginPage({
    searchParams,
}: {
    searchParams: Promise<{ error?: string }>;
}) {
    return (
        <div className="min-h-screen flex items-center justify-center bg-gray-50">
            <div className="w-full max-w-sm bg-white rounded-xl shadow p-8 flex flex-col gap-6">
                <div>
                    <h1 className="text-xl font-semibold text-gray-900">GDG Collect</h1>
                    <p className="text-sm text-gray-500 mt-1">Admin sign in</p>
                </div>

                <form action={login} className="flex flex-col gap-4">
                    <div className="flex flex-col gap-1">
                        <label htmlFor="email" className="text-sm font-medium text-gray-700">
                            Email
                        </label>
                        <input
                            id="email"
                            name="email"
                            type="email"
                            required
                            className="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                        />
                    </div>

                    <div className="flex flex-col gap-1">
                        <label htmlFor="password" className="text-sm font-medium text-gray-700">
                            Password
                        </label>
                        <input
                            id="password"
                            name="password"
                            type="password"
                            required
                            className="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                        />
                    </div>

                    <ErrorMessage searchParams={searchParams} />

                    <button
                        type="submit"
                        className="bg-blue-600 text-white rounded-lg px-4 py-2 text-sm font-medium hover:bg-blue-700 transition-colors"
                    >
                        Sign in
                    </button>
                </form>
            </div>
        </div>
    );
}

async function ErrorMessage({
    searchParams,
}: {
    searchParams: Promise<{ error?: string }>;
}) {
    const params = await searchParams;
    if (!params.error) return null;
    return (
        <p className="text-sm text-red-600">{params.error}</p>
    );
}
