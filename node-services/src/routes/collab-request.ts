import { Request, Response, NextFunction } from "express";
import { check, sanitize } from "express-validator";
import { UserDocument } from "../models/User";
import { CollabRequest, toHtmlAndTextForEmail } from "../models/CollabRequest";
import { sendEmail } from "../util/email";


export const postCollabRequestValidators = [
    check("field", "Field cannot be blank").isLength({min: 1}),
    check("subject", "Subject cannot be blank").isLength({min: 1}),
    check("projectImpactSummary", "Projct impact summary cannot be blank").isLength({min: 1}),
    check("expectedTasks", "Expected tasks cannot be blank").isLength({min: 1}),
    check("expectedSkills", "Expected skills cannot be blank").isLength({min: 1}),
    check("expectedTime", "Expected time cannot be blank").isLength({min: 1}),
    check("offer", "Offer time cannot be blank").isLength({min: 1}),
];


/**
 * POST /collab-requests
 * Create a new collab-request for the currently logged-in user.
 */
export const postCollabRequest = (req: Request, res: Response, next: NextFunction) => {

    if (!req.user) {
        return res.sendStatus(401);
    }

    const user = req.user as UserDocument;

    const collabRequest = new CollabRequest({
        field: req.body.field,
        subject: req.body.subject,
        projectImpactSummary: req.body.projectImpactSummary,
        expectedTasks: req.body.expectedTasks,
        expectedSkills: req.body.expectedSkills,
        expectedTime: req.body.expectedTime,
        offer: req.body.offer,
        additionalInfo: req.body.additionalInfo,
        userId: user.id,
        invitedCollabs: []
    });

    collabRequest.save((err, collabRequest) => {
        if (err) { return next(err); }

        return res.status(200).json({ collabRequestId: collabRequest.id });
    });

};


/**
 * GET /collab-requests/:id
 * Gets a collab-request by it's ID.
 */
export const getCollabRequest = (req: Request, res: Response, next: NextFunction) => {
    const collabRequestId = req.params.id;

    CollabRequest.findById(collabRequestId).exec((err, collabRequest) => {
        if (err) {
            return next(err);
        }

        return res.status(200).json(collabRequest);
    });
}


/**
 * GET /collab-requests
 * Get the collab requests created by the current logged in user.
 */
export const getCollabRequests = (req: Request, res: Response, next: NextFunction) => {

    if (!req.user) {
        return res.sendStatus(401);
    }

    const user = req.user as UserDocument;

    CollabRequest.find({ userId: user.id }, (err, collabRequests) => {

        if (err) {
            return next(err);
        }

        return res.status(200).json(collabRequests);
    });

}


export const postCollabRequestInvitesValidators = [
    check("invitedCollabEmail", "Email is not valid").isEmail(),
    // eslint-disable-next-line @typescript-eslint/camelcase
    sanitize("invitedCollabEmail").normalizeEmail({ gmail_remove_dots: false })
];


export const postCollabRequestInvites = async (req: Request, res: Response, next: NextFunction) => {

    if (!req.user) {
        return res.sendStatus(401);
    }

    const user = req.user as UserDocument;
    const invitedCollabEmail = req.body.invitedCollabEmail;

    CollabRequest.findOneAndUpdate(
        {
            _id: req.params.id,
            userId: user.id,
            invitedCollabs: { $nin: [ invitedCollabEmail ] },
        },
        {
            $push: {
                invitedCollabs: invitedCollabEmail
            }
        },
        async (err, collabRequest) => {

            if (err) {
                return next(err);
            }

            if (!collabRequest) {
                return res.status(500).json({ err: 1 });
            }

            const { html, text } = toHtmlAndTextForEmail(collabRequest);

            try {
                await sendEmail({
                    from: "invite@gradcollab.com",
                    to: invitedCollabEmail,
                    subject: "You have received an invitation to collaborate on a research project",
                    text,
                    html
                });
                return res.status(200).json({ ok: 1 });

            } catch (err) {
                return next(err);
            }
        }
    )

}
