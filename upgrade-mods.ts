import fs from "fs/promises";
import path from "path";
import got from "got";
import { execa } from "execa";
import semver from "semver";
import { Octokit } from "@octokit/rest";
import { fileURLToPath } from "url";
import { dirname } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const octokit = new Octokit({
  auth: process.env.OCTOKIT_AUTH_TOKEN,
});

const serverSourceModPath = path.resolve(
  __dirname,
  "sourcemod",
  "server_sourcemod.sh"
);

const readmePath = path.join(__dirname, "README.md");

const isCI = process.env.CI === "true";

async function getLastCommitHash() {
  const { stdout } = await execa("git", ["rev-parse", "--short", "HEAD"]);
  return stdout;
}

async function upgradeMod({
  mod,
  downloadPageUrl,
  versionBuildNumberRegExp,
  versionReplaceRegExp,
  readmeVersionReplaceRegExp,
  buildNumberReplaceRegExp,
  readmeBuildNumberReplaceRegExp,
}: {
  mod: string;
  downloadPageUrl: string;
  versionBuildNumberRegExp: RegExp;
  versionReplaceRegExp: RegExp;
  readmeVersionReplaceRegExp: RegExp;
  buildNumberReplaceRegExp: RegExp;
  readmeBuildNumberReplaceRegExp: RegExp;
}) {
  const { body } = await got(downloadPageUrl);
  const match = body.match(versionBuildNumberRegExp);

  if (match) {
    const [_, version, buildNumber] = match;

    const serverSourceModFile = await fs.readFile(serverSourceModPath, "utf-8");
    const changedServerSourceModFile = serverSourceModFile
      .replace(versionReplaceRegExp, `$1${version}$2`)
      .replace(buildNumberReplaceRegExp, `$1${buildNumber}$2`);

    if (serverSourceModFile === changedServerSourceModFile) {
      console.log(`no upgrade available for ${mod}`);
    } else {
      const commitMessage = `upgrade ${mod} to version ${version} build ${buildNumber}`;

      await fs.writeFile(serverSourceModPath, changedServerSourceModFile);

      const readmeFile = await fs.readFile(readmePath, "utf-8");

      const changedReadmeFile = readmeFile
        .replace(readmeVersionReplaceRegExp, `$1${version}$2`)
        .replace(readmeBuildNumberReplaceRegExp, `$1${buildNumber}$2`);

      await fs.writeFile(readmePath, changedReadmeFile);

      if (isCI) {
        await execa("git", ["commit", "-am", commitMessage]);

        return [await getLastCommitHash(), commitMessage];
      }

      console.log(commitMessage);
    }
  }
}

async function upgradeMods() {
  try {
    const upgradedModsCommits = [
      await upgradeMod({
        mod: "sourcemod",
        downloadPageUrl:
          "https://www.sourcemod.net/downloads.php?branch=stable",
        versionBuildNumberRegExp:
          /<a class='quick-download download-link' href='https:\/\/sm\.alliedmods\.net\/smdrop\/\d+.\d+\/sourcemod-(\d+.\d+.\d+)-git(\d+)-linux\.tar.gz'>/,
        versionReplaceRegExp: /(\${SOURCEMOD_VERSION-")\d+\.\d+.\d+("}")/,
        readmeVersionReplaceRegExp:
          /(##### `SOURCEMOD_VERSION`\n\n.+\n\nDefault: `)[0-9.]+(`)/,
        buildNumberReplaceRegExp: /(\${SOURCEMOD_BUILD-)\d+(})/,
        readmeBuildNumberReplaceRegExp:
          /(##### `SOURCEMOD_BUILD`\n\n.+\n\nDefault: `)[0-9]+(`)/,
      }),
      await upgradeMod({
        mod: "metamod",
        downloadPageUrl: "https://www.sourcemm.net/downloads.php?branch=stable",
        versionBuildNumberRegExp:
          /<a class='quick-download download-link' href='https:\/\/mms\.alliedmods\.net\/mmsdrop\/\d+.\d+\/mmsource-(\d+.\d+.\d+)-git(\d+)-linux\.tar.gz'>/,
        versionReplaceRegExp: /(\${METAMOD_VERSION-")\d+\.\d+.\d+("}")/,
        readmeVersionReplaceRegExp:
          /(##### `METAMOD_VERSION`\n\n.+\n\nDefault: `)[0-9.]+(`)/,
        buildNumberReplaceRegExp: /(\${METAMOD_BUILD-)\d+(})/,
        readmeBuildNumberReplaceRegExp:
          /(##### `METAMOD_BUILD`\n\n.+\n\nDefault: `)[0-9]+(`)/,
      }),
    ].filter(Boolean);

    if (isCI && Boolean(upgradedModsCommits.length)) {
      await execa("git", ["push"]);

      const [repoOwner, repoName] = process.env.GITHUB_REPOSITORY!.split("/");

      const {
        data: { tag_name: lastVersionTag },
      } = await octokit.rest.repos.getLatestRelease({
        owner: repoOwner,
        repo: repoName,
      });

      const newVersionTag = semver.inc(lastVersionTag, "patch");

      if (!newVersionTag) {
        throw Error(`Could not bump version tag from ${lastVersionTag}`);
      }

      await octokit.rest.repos.createRelease({
        owner: repoOwner,
        repo: repoName,
        tag_name: newVersionTag,
        name: `v${newVersionTag}`,
        body: `## Changes\n${upgradedModsCommits.reduce((acc, upgradedMod) => {
          if (upgradedMod) {
            const [commitHash, commitMessage] = upgradedMod;
            return `${acc}\n- sourcemod, pug-practice: ${commitMessage} ${commitHash}`;
          }
          return acc;
        }, "")}`,
      });
    }
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
}

upgradeMods();
