//
// Created by Esteban Torres on 17.04.17.
// Copyright (c) 2017 Esteban Torres. All rights reserved.
//

import Foundation

internal class StatusMapper: ModelMapping {
    typealias Model = Status

    func map(json: ModelMapping.JSONDictionary) -> Result<Model, MammutAPIError.MappingError> {
        let accountMapper = AccountMapper()
        guard
                let id = json["id"] as? Int,
                let createdAtString = json["created_at"] as? String,
                let createdAt = Date(from: createdAtString),
                let sensitive = json["sensitive"] as? Bool,
                let visibilityText = json["visibility"] as? String,
                let visibility = StatusVisibility(rawValue: visibilityText),
                let accountDict = json["account"] as? [String: Any],
                let account = accountMapper.map(json: accountDict).value,
                let mediaAttachments = json["media_attachments"] as? [ModelMapping.JSONDictionary],
                let mentions = json["mentions"] as? [ModelMapping.JSONDictionary],
                let tagsDictionary = json["tags"] as? [ModelMapping.JSONDictionary],
                let uri = json["uri"] as? String,
                let content = json["content"] as? String,
                let urlString = json["url"] as? String,
                let url = URL(string: urlString),
                let reblogsCount = json["reblogs_count"] as? Int,
                let favouritesCount = json["favourites_count"] as? Int
                else {
            return .failure(MammutAPIError.MappingError.incompleteModel)
        }

        let applicationMapper = ApplicationMapper()
        let attachmentMapper = AttachmentMapper()
        let mentionMapper = MentionMapper()
        let tagMapper = TagMapper()
        let statusMapper = StatusMapper()

        let inReplyToId = json["in_reply_to_id"] as? String
        let inReplyToAccountId = json["in_reply_to_account_id"] as? String
        let spoilerText = json["spoiler_test"] as? String
        var application: Application? = nil
        if let applicationDict = json["application"] as? JSONDictionary,
           case let .success(app) = applicationMapper.map(json: applicationDict) {
            application = app
        }

        let favourited = (json["favourited"] as? Bool) ?? false
        let reblogged = (json["reblogged"] as? Bool) ?? false

        var reblog: Status? = nil
        if let reblogDictionary = json["reblog"] as? ModelMapping.JSONDictionary,
            case let .success(mReblog) = statusMapper.map(json: reblogDictionary) {
            reblog = mReblog
        }

        var attachments: [Attachment] = []
        if case let .success(mAttachments) = attachmentMapper.map(array: mediaAttachments) {
            attachments = mAttachments
        }
        var mappedMentions: [Mention] = []
        if case let .success(mMentions) = mentionMapper.map(array: mentions) {
            mappedMentions = mMentions
        }

        var tags: [Tag] = []
        if case let .success(mTags) = tagMapper.map(array: tagsDictionary) {
            tags = mTags
        }

        let status = Status(
                id: id,
                createdAt: createdAt,
                inReplyToId: inReplyToId,
                inReplyToAccountId: inReplyToAccountId,
                sensitive: sensitive,
                spoilerText: spoilerText,
                visibility: visibility,
                application: application,
                account: account,
                mediaAttachments: attachments,
                mentions: mappedMentions,
                tags: tags,
                uri: uri,
                content: content,
                url: url,
                reblogsCount: reblogsCount,
                favouritesCount: favouritesCount,
                reblog: reblog,
                favourited: favourited,
                reblogged: reblogged
        )

        return .success(status)
    }

}
