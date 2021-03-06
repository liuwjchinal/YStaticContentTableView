//
//  YStaticContentTableViewDelegate.m
//  Pods
//
//  Created by 李遵源 on 2017/3/6.
//
//

#import "YStaticContentTableViewDelegate.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "UITableView+YStaticContentTableViewPrivate.h"
#import "UITableView+YStaticContentTableView.h"

@interface YStaticContentTableViewDelegate()

@end

@implementation YStaticContentTableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    YStaticContentTableViewSection *sectionContent = tableView.y_staticContentSections[indexPath.section];
    YStaticContentTableViewCellExtraInfo *cellContent = [sectionContent cellInfoForRow:indexPath.row];
    
    if (cellContent.cellHeight == -1) {
        if (tableView.rowHeight == -1) {
            //判断是否有缓存，如果有则读取
            if (cellContent.heightCacheType == YStaticContentHeightCacheTypeIndexPath) {
                if ([tableView.fd_indexPathHeightCache existsHeightAtIndexPath:indexPath]) {
                    return [tableView.fd_indexPathHeightCache heightForIndexPath:indexPath];
                }
            } else {
                NSString *key;
                if (cellContent.heightCacheType == YStaticContentHeightCacheTypeReuseIdentifier) {
                    key = cellContent.reuseIdentifier;
                } else {
                    key = cellContent.customIdentifier;
                }
                
                if ([tableView.fd_keyedHeightCache existsHeightForKey:key]) {
                    return [tableView.fd_keyedHeightCache heightForKey:key];
                }
            }
            //找不到缓存,开始计算高度
            CGFloat cellHeight = [tableView fd_heightForCellWithIdentifier:cellContent.reuseIdentifier configuration:^(UITableViewCell *cell) {
                cellContent.configureBlock(nil, cell, indexPath);
                //如果一个约束都没事 就变成frameLayout
                if (cell.contentView.constraints.count == 0 && cell.constraints.count == 0) {
                    cell.fd_enforceFrameLayout = YES;
                } else {
                    if (cellContent.layoutType == YStaticContentLayoutTypeFrame) {
                        cell.fd_enforceFrameLayout = YES;
                    } else {
                        cell.fd_enforceFrameLayout = NO;
                    }
                }
            }];
            
            //存入缓存
            if (cellContent.heightCacheType == YStaticContentHeightCacheTypeIndexPath) {
                [tableView.fd_indexPathHeightCache cacheHeight:cellHeight byIndexPath:indexPath];
            } else {
                NSString *key;
                if (cellContent.heightCacheType == YStaticContentHeightCacheTypeReuseIdentifier) {
                    key = cellContent.reuseIdentifier;
                } else {
                    key = cellContent.customIdentifier;
                }
                [tableView.fd_keyedHeightCache cacheHeight:cellHeight byKey:key];
            }
            return cellHeight;
        }
        return tableView.rowHeight;
    }
    return cellContent.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    YStaticContentTableViewSection *sectionContent = tableView.y_staticContentSections[section];
    UIView *headerView = sectionContent.headerView;
    if (headerView) {
        return CGRectGetHeight(headerView.frame);
    }
    
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    YStaticContentTableViewSection *sectionContent = tableView.y_staticContentSections[section];
    UIView *footerView = sectionContent.footerView;
    if (footerView) {
        return CGRectGetHeight(footerView.frame);
    }
    
    return UITableViewAutomaticDimension;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    YStaticContentTableViewSection *sectionContent = tableView.y_staticContentSections[indexPath.section];
    YStaticContentTableViewCellExtraInfo *cellContent = [sectionContent cellInfoForRow:indexPath.row];
    
    return cellContent.editingStyle;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    YStaticContentTableViewSection *sectionContent = tableView.y_staticContentSections[indexPath.section];
    YStaticContentTableViewCellExtraInfo *cellContent = [sectionContent cellInfoForRow:indexPath.row];
    
    return cellContent.editable;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    YStaticContentTableViewSection *sectionContent = tableView.y_staticContentSections[indexPath.section];
    YStaticContentTableViewCellExtraInfo *cellContent = [sectionContent cellInfoForRow:indexPath.row];
    
    return cellContent.moveable;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    YStaticContentTableViewSection *sectionContent = tableView.y_staticContentSections[indexPath.section];
    YStaticContentTableViewCellExtraInfo *cellContent = [sectionContent cellInfoForRow:indexPath.row];
    
    if(cellContent.whenSelectedBlock) {
        cellContent.whenSelectedBlock(indexPath);
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [scrollView endEditing:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    YStaticContentTableViewSection *sectionContent = tableView.y_staticContentSections[section];
    return sectionContent.headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    YStaticContentTableViewSection *sectionContent = tableView.y_staticContentSections[section];
    return sectionContent.footerView;
}

@end
