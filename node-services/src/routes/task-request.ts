import { Request, Response, NextFunction } from "express";
import { check } from "express-validator";
import { User, UserDocument, prepareForClient } from "../models/User";
import { TaskRequest } from "../models/TaskRequest";


export const postTaskRequestValidators = [
    check("field", "Field cannot be blank").isLength({min: 1}),
    check("subject", "Subject cannot be blank").isLength({min: 1}),
    check("projectImpactSummary", "Projct impact summary cannot be blank").isLength({min: 1}),
    check("expectedTasksAndSkills", "Expected tasks and skills cannot be blank").isLength({min: 1}),
    check("reward", "Reward cannot be blank").isLength({min: 1}),
];


/**
 * POST /task-requests
 * Create a new task-request for the currently logged-in user.
 */
export const postTaskRequest = (req: Request, res: Response, next: NextFunction) => {

    if (!req.user) {
        return res.sendStatus(401);
    }

    const user = req.user as UserDocument;

    const taskRequest = new TaskRequest({
        field: req.body.field,
        subject: req.body.subject,
        projectImpactSummary: req.body.projectImpactSummary,
        expectedTasksAndSkills: req.body.expectedTasksAndSkills,
        reward: req.body.reward,
        additionalInfo: req.body.additionalInfo,
        userId: user.id
    });

    taskRequest.save((err, taskRequest) => {
        if (err) { return next(err); }

        return res.status(200).json({ taskRequestId: taskRequest.id });
    });

};


/**
 * GET /task-requests/:id
 *
 * Gets a task-request by it's ID. An optional `withUser` query param attaches the owner to the result.
 */
export const getTaskRequest = (req: Request, res: Response, next: NextFunction) => {
    const taskRequestId = req.params.id;
    const withUser = req.query.withUser === "1";

    TaskRequest.findById(taskRequestId).exec((err, taskRequest) => {
        if (err) {
            return next(err);
        }

        if (!withUser) {
            return res.status(200).json(taskRequest);
        }

        User.findById(taskRequest.userId, (err, user) => {

            if (err) {
                return next(err);
            }

            const result = {
                user: prepareForClient(user),
                taskRequest
            };

            return res.status(200).json(result);
        });

    });
};


/**
 * GET /task-requests
 * Get the task-requests created by the current logged in user.
 */
export const getTaskRequests = (req: Request, res: Response, next: NextFunction) => {

    if (!req.user) {
        return res.sendStatus(401);
    }

    const user = req.user as UserDocument;

    TaskRequest.find({ userId: user.id }, (err, taskRequests) => {

        if (err) {
            return next(err);
        }

        return res.status(200).json(taskRequests);
    });

};