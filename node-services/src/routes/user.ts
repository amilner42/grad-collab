import passport from "passport";
import { FormError } from "../util/form";
import { User, UserDocument } from "../models/User";
import { Request, Response, NextFunction } from "express";
import { check, sanitize, validationResult } from "express-validator";
import "../config/passport";


/**
 * GET /me
 * Gets the currently logged in user.
 */
export const getCurrentUser = (req: Request, res: Response, next: NextFunction) => {

    if (!req.user) {
        return res.sendStatus(401);
    }

    const user = req.user as UserDocument;

    return res.json({ email: user.email, _id: user.id });
};


export const postLoginValidator = [
    check("email", "Email is not valid").isEmail(),
    check("password", "Password cannot be blank").isLength({min: 1}),
    // eslint-disable-next-line @typescript-eslint/camelcase
    sanitize("email").normalizeEmail({ gmail_remove_dots: false })
];


/**
 * POST /login
 * Sign in using email and password.
 */
export const postLogin = (req: Request, res: Response, next: NextFunction) => {

    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(403).json(errors.mapped());
    }

    passport.authenticate("local", (err: Error, user: UserDocument, formError: FormError) => {
        if (err) { return next(err); }
        if (!user) {
            return res.status(403).json(formError);
        }
        req.logIn(user, (err) => {
            if (err) { return next(err); }
            return res.json({ email: user.email, _id: user.id });
        });
    })(req, res, next);
};


/**
 * POST /logout
 * Log out.
 */
export const postLogout = (req: Request, res: Response) => {
    req.logout();
    res.json({});
};


export const postRegisterValidator = [
    check("email", "Email is not valid").isEmail(),
    check("password", "Password must be at least 6 characters long").isLength({ min: 6 }),
    // eslint-disable-next-line @typescript-eslint/camelcase
    sanitize("email").normalizeEmail({ gmail_remove_dots: false })
];


/*
 * POST /signup
 * Create a new local account.
 */
export const postRegister = (req: Request, res: Response, next: NextFunction) => {

    const errors = validationResult(req);

    console.log(`err: ${JSON.stringify(errors)}`);

    if (!errors.isEmpty()) {
        return res.status(403).json(errors.mapped());
    }

    const user = new User({
        email: req.body.email,
        password: req.body.password
    });

    User.findOne({ email: req.body.email }, (err, existingUser) => {
        if (err) { return next(err); }
        if (existingUser) {
            return res.status(403).json({
                entire: [],
                fields: { "email": "Account with that email address already exists." }
            });
        }
        user.save((err) => {
            if (err) { return next(err); }
            req.logIn(user, (err) => {
                if (err) {
                    return next(err);
                }
                return res.json({ email: user.email, _id: user.id });
            });
        });
    });
};


export const patchUpdateUserValidators = [
    check("name").isString(),
    check("field").isString(),
    check("specialization").isString(),
    check("currentAvailability").isString(),
    check("supervisorEmail").isString(),
    check("researchExperience").isString(),
    check("university").isString(),
    check("degreesHeld").isString(),
    check("shortBio").isString(),
    check("linkedInUrl").isString(),
    check("researchPapers").isString()
];


/**
 *
 */
export const patchUpdateUser = (req: Request, res: Response, next: NextFunction) => {

    if (!req.user) {
        return res.sendStatus(401);
    }

    const user = req.user as UserDocument;

    const userId = req.params.id;
    if ( user.id !== userId ) {
        return res.sendStatus(403);
    }

    const updateFields = req.body;

    return User.update({ _id: userId }, updateFields).exec()
    .then((val) => {

        console.log(`a: ${JSON.stringify(val)}`)
        if (val.nModified !== 1 || val.ok !== 1) {
            return next("Failed to update");
        }

        return res.status(200).json({ ok: 1 });
    })
    .catch((err) => {
        return next(err);
    });
}


// /**
//  * GET /users/:id
//  * Gets the public information for a specific user.
//  */
// export const  getUser = (req: Request, res: Response, next: NextFunction) => {
//
//     const userId = req.params.id;
//
//     User.findById(userId, (err, user) => {
//         if (err) {
//             return next(err);
//         }
//
//         delete user.password;
//     });
// }
