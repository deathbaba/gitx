//
//  PBGitIndexController.h
//  GitX
//
//  Created by Pieter de Bie on 18-11-08.
//  Copyright 2008 Pieter de Bie. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PBGitCommitController.h"
#import "PBChangedFile.h"

@interface PBGitIndexController : NSObject {
	IBOutlet NSArrayController *stagedFilesController;
	IBOutlet NSArrayController *unstagedFilesController;
	IBOutlet PBGitCommitController *commitController;

	IBOutlet NSTableView *unstagedTable;
	IBOutlet NSTableView *stagedTable;	
}

@property (readonly) NSArrayController *stagedFilesController;
@property (readonly) NSArrayController *unstagedFilesController;
@property (readonly) NSTableView *unstagedTable;
@property (readonly) NSTableView *stagedTable;

- (IBAction) rowClicked:(NSCell *) sender;
- (IBAction) tableClicked:(NSTableView *)tableView;

- (NSMenu *) menuForTable:(NSTableView *)table;
- (NSView *) nextKeyViewFor:(NSView *)view;
- (NSView *) previousKeyViewFor:(NSView *)view;

- (void) stageSelectedFiles;
- (void) unstageSelectedFiles;
- (void) discardChangesForFiles:(NSArray<PBChangedFile *> *)files force:(BOOL)force;
- (void) moveToTrash:(NSArray<PBChangedFile *> *)files;

+ (NSString *) getNameOfFirstFile:(NSArray<PBChangedFile *> *) selectedFiles;
+ (BOOL) canDiscardAnyFileIn:(NSArray<PBChangedFile *> *)files;
+ (BOOL) shouldTrashInsteadOfDiscardAnyFileIn:(NSArray<PBChangedFile *> *)files;

@end
