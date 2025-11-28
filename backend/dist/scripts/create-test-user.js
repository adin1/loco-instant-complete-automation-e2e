"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
require("dotenv/config");
const auth_service_1 = require("../src/modules/auth/auth.service");
async function main() {
    var _a;
    const auth = new auth_service_1.AuthService();
    const email = 'demo@loco-instant.ro';
    const password = 'Parola123!';
    const name = 'Demo User';
    try {
        const user = await auth.register(email, password, name);
        console.log('Created demo user:', { id: user['id'], email: user['email'] });
    }
    catch (e) {
        console.error('Could not create demo user:', (_a = e === null || e === void 0 ? void 0 : e.message) !== null && _a !== void 0 ? _a : e);
    }
    finally {
        process.exit(0);
    }
}
main().catch((e) => {
    console.error('Unexpected error while creating demo user:', e);
    process.exit(1);
});
//# sourceMappingURL=create-test-user.js.map