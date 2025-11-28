"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const client_1 = require("@prisma/client");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
let AuthService = class AuthService {
    constructor() {
        this.prisma = new client_1.PrismaClient();
    }
    async register(email, password, name) {
        const existing = await this.prisma.user.findUnique({ where: { email } });
        if (existing) {
            throw new Error('User already exists');
        }
        const hashedPassword = await bcrypt.hash(password, 10);
        const newUser = await this.prisma.user.create({
            data: {
                email,
                password: hashedPassword,
                name,
            },
        });
        return newUser;
    }
    async validateUser(email, password) {
        const user = await this.prisma.user.findUnique({ where: { email } });
        if (!user) {
            throw new Error('User not found');
        }
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            throw new Error('Invalid password');
        }
        return user;
    }
    async login(email, password) {
        if (email === 'demo@loco-instant.ro' &&
            password === 'Parola123!' &&
            (process.env.ALLOW_DEMO_LOGIN === '1' || process.env.NODE_ENV !== 'production')) {
            const demoUser = {
                id: -1,
                email,
                password: '',
                name: 'Demo User',
            };
            const payload = { sub: demoUser.id, email: demoUser.email };
            const token = jwt.sign(payload, process.env.JWT_SECRET || 'local_secret_key', {
                expiresIn: '7d',
            });
            return {
                access_token: token,
                user: demoUser,
            };
        }
        const user = await this.validateUser(email, password);
        const payload = { sub: user.id, email: user.email };
        const token = jwt.sign(payload, process.env.JWT_SECRET || 'local_secret_key', {
            expiresIn: '7d',
        });
        return {
            access_token: token,
            user,
        };
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)()
], AuthService);
//# sourceMappingURL=auth.service.js.map