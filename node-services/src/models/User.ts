import bcrypt from "bcrypt-nodejs";
import mongoose from "mongoose";
import R from "ramda";


export type UserDocument = mongoose.Document & {
    email: string;
    password: string;
    name: string;
    field: string | null;
    specialization: string;
    currentAvailability: string;
    supervisorEmail: string;
    researchExperienceAndPapers: string;
    university: string;
    degreesHeld: string;
    shortBio: string;
    linkedInUrl: string;

    comparePassword: comparePasswordFunction;
};

type comparePasswordFunction = (candidatePassword: string, cb: (err: any, isMatch: any) => {}) => void;

const userSchema = new mongoose.Schema({
    email: { type: String, unique: true },
    password: String,

    name: String,
    field: String,
    specialization: String,
    currentAvailability: String,
    supervisorEmail: String,
    researchExperienceAndPapers: String,
    university: String,
    degreesHeld: String,
    shortBio: String,
    linkedInUrl: String,

}, { timestamps: true });

/**
 * Password hash middleware.
 */
userSchema.pre("save", function save(next) {
    const user = this as UserDocument;
    if (!user.isModified("password")) { return next(); }
    bcrypt.genSalt(10, (err, salt) => {
        if (err) { return next(err); }
        bcrypt.hash(user.password, salt, undefined, (err: mongoose.Error, hash) => {
            if (err) { return next(err); }
            user.password = hash;
            next();
        });
    });
});

const comparePassword: comparePasswordFunction = function (candidatePassword, cb) {
    bcrypt.compare(candidatePassword, this.password, (err: mongoose.Error, isMatch: boolean) => {
        cb(err, isMatch);
    });
};

userSchema.methods.comparePassword = comparePassword;


export const prepareForClient = (user: UserDocument) => {
    return R.pick([
        "_id",
        "email",
        "name",
        "field",
        "specialization",
        "currentAvailability",
        "supervisorEmail",
        "researchExperienceAndPapers",
        "university",
        "degreesHeld",
        "shortBio",
        "linkedInUrl",
    ], user);
};


export const User = mongoose.model<UserDocument>("User", userSchema);
