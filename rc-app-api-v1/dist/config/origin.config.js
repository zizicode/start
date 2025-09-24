"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.allowedOrigins = void 0;
const dot_config_1 = __importDefault(require("../config/dot.config"));
exports.allowedOrigins = [`http://localhost:${dot_config_1.default.PORT}`, "https://rodolfocordones.com"];
