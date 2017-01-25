'use strict';

const fs = require('fs');
const spawnSync = require('child_process').spawnSync;

/** The version of R */
const version = '3.3.2';

function spawn(command, args) {
    const output = spawnSync(command, args);
    if (output.error != null) {
        console.log(output);
        return output.error.toString();
    }
    const s = output.stdout.toString() + output.stderr.toString();
    console.log(s);
    return s;
}

function install_r() {
    if (fs.existsSync('/tmp/.linuxbrew'))
        return;
    fs.mkdirSync('/tmp/.linuxbrew');
    fs.mkdirSync('/tmp/.linuxbrew/lib');
    fs.symlinkSync('/lib64/ld-linux-x86-64.so.2', '/tmp/.linuxbrew/lib/ld.so');
    fs.mkdirSync('/tmp/.linuxbrew/Cellar');
    spawn('tar', ['xf', `/var/task/r-${version}.x86_64_linux.bottle.tar.gz`, '-C', '/tmp/.linuxbrew/Cellar']);
    process.env.HOME = '/tmp';
    process.env.LD_LIBRARY_PATH = '/var/task/lib:/tmp/.linuxbrew/Cellar/r/3.3.2/lib/R/lib';
    process.chdir('/tmp');
}

function eval_r(expr) {
    return spawn(`/tmp/.linuxbrew/Cellar/r/${version}/bin/Rscript`, ['-e', expr])
}

/**
 * Transfer bottles from CircleCI to BinTray and GitHub
 */
exports.handler = (event, context, callback) => {
    console.log('Received event:', JSON.stringify(event, null, 2));

    const done = (err, res) => callback(null, {
        statusCode: err ? '400' : '200',
        body: err ? err.message : res,
        headers: {
            'Content-Type': 'text/plain',
        },
    });

    const redirect = (url) => callback(null, {
        statusCode: 303,
        headers: { 'Content-Type': 'text/html', 'Location': url },
        body: `<html><body>You are being <a href="${url}">redirected</a>.</body></html>`
    });

    switch (event.httpMethod) {
        case 'GET':
            if (event.queryStringParameters == null || !('e' in event.queryStringParameters)) {
                redirect('https://github.com/sjackman/lambdar');
                break;
            }
        case 'POST':
            const expr = event.httpMethod == "GET" ? event.queryStringParameters.e : event.body;
            console.log(expr);
            install_r();
            done(null, eval_r(expr));
            break;
        default:
            done(new Error(`Unsupported method "${event.httpMethod}"`));
    }
};
