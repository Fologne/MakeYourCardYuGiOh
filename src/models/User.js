import { calculateAge } from '../utils/validation.js';
import mongoose from 'mongoose';

// Schema do modelo de Usuario conforme especificacoes da Etapa 4
const userSchema = new mongoose.Schema(
  {
    firstName: {
      type: String,
      required: [true, 'Nome e obrigatorio'],
      trim: true,
    },
    lastName: {
      type: String,
      required: [true, 'Sobrenome e obrigatorio'],
      trim: true,
    },
    username: {
      type: String,
      required: [true, 'Nome de usuario e obrigatorio'],
      unique: true,
      trim: true,
      lowercase: true,
      minlength: [3, 'Nome de usuario deve ter no minimo 3 caracteres'],
    },
    email: {
      type: String,
      required: [true, 'E-mail e obrigatorio'],
      unique: true,
      trim: true,
      lowercase: true,
      match: [/\S+@\S+\.\S+/, 'Formato de e-mail invalido'],
    },
    birthDate: {
      type: Date,
      required: [true, 'Data de nascimento e obrigatoria'],
    },
    age: {
      type: Number,
      min: [6, 'Idade minima e de 6 anos'],
    },
    gender: {
      type: String,
      enum: ['Masculino', 'Feminino', 'Outro', 'Prefiro nao informar'],
      default: 'Prefiro nao informar',
    },
    gameOrigin: {
      type: String,
      enum: ['TCG', 'OCG', 'Master Duel', 'Duel Links'],
      default: 'TCG',
    },
    password: {
      type: String,
      required: [true, 'Senha e obrigatoria'],
      minlength: [6, 'Senha deve ter no minimo 6 caracteres'],
    },
    accountId: {
      type: String,
      required: [true, 'ID da conta e obrigatorio'],
      unique: true,
      index: true,
    },
    plan: {
      type: String,
      enum: ['Gratuito', 'Premium', 'Duelista Lendario'],
      default: 'Gratuito',
    },
    preferredPronoun: {
      type: String,
      default: 'Duelista',
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    sessionVersion: { type: Number, default: 0, select: false },
  },
  {
    timestamps: true,
  }
);

// Atualiza idade antes da validacao do documento.
userSchema.pre('validate', function () {
  if (this.birthDate) this.age = calculateAge(this.birthDate);
});

// Metodo para retornar o objeto do usuario seguro (sem a senha)
userSchema.methods.toSafeObject = function () {
  const obj = this.toObject({ virtuals: true });
  if (this.birthDate) obj.age = calculateAge(this.birthDate);
  delete obj.password;
  delete obj.sessionVersion;
  return obj;
};

const User = mongoose.model('User', userSchema);

export default User;
