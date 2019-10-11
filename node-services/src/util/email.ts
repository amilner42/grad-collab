import sgMail from "@sendgrid/mail";


interface SendEmailConfig {
    to: string;
    from: string;
    subject: string;
    text: string;
    html: string;
}


export interface HtmlAndText {
    html: string;
    text: string;
}


/**
 * Send an email.
 */
export const sendEmail = async (config: SendEmailConfig) => {
    // TODO move to secrets.ts
    sgMail.setApiKey(process.env.SENDGRID_API_KEY);

    return sgMail.send(config);
}
